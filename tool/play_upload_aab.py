#!/usr/bin/env python3
"""Upload the release AAB to a Play track (default: internal) and create a
release with localized notes from the fastlane changelogs. Commits the edit.

    python3 tool/play_upload_aab.py [track]

The app stays in Draft until you publish in the Console; for an internal track
this just stages the release for your internal testers.
"""
import os
import socket
import sys

socket.setdefaulttimeout(600)  # large AAB upload — don't read-timeout mid-chunk

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload

KEY = 'fastlane/play-store-key.json'
PKG = 'ch.knabberfuchs.app'
AAB = 'build/app/outputs/bundle/release/app-release.aab'
META = 'fastlane/metadata/android'
TRACK = sys.argv[1] if len(sys.argv) > 1 else 'internal'
SCOPES = ['https://www.googleapis.com/auth/androidpublisher']


def release_notes(version_code):
    notes = []
    for loc in sorted(os.listdir(META)):
        p = os.path.join(META, loc, 'changelogs', f'{version_code}.txt')
        if os.path.isfile(p):
            with open(p, encoding='utf-8') as f:
                notes.append({'language': loc, 'text': f.read().strip()})
    return notes


def main():
    creds = service_account.Credentials.from_service_account_file(
        KEY, scopes=SCOPES)
    svc = build('androidpublisher', 'v3', credentials=creds,
                cache_discovery=False)
    edit_id = svc.edits().insert(packageName=PKG, body={}).execute()['id']
    print('edit %s — uploading %s (%.0f MB)' % (
        edit_id, AAB, os.path.getsize(AAB) / 1e6))
    try:
        req = svc.edits().bundles().upload(
            packageName=PKG, editId=edit_id,
            media_body=MediaFileUpload(
                AAB, mimetype='application/octet-stream', resumable=True,
                chunksize=10 * 1024 * 1024))
        resp = None
        while resp is None:
            status, resp = req.next_chunk(num_retries=5)
            if status:
                print('  %d%%' % int(status.progress() * 100))
        vc = resp['versionCode']
        print('uploaded versionCode %s' % vc)

        svc.edits().tracks().update(
            packageName=PKG, editId=edit_id, track=TRACK,
            body={'track': TRACK,
                  'releases': [{'versionCodes': [str(vc)],
                                'status': 'completed',
                                'releaseNotes': release_notes(vc)}]}
        ).execute()
        print('assigned to track "%s"' % TRACK)

        try:
            svc.edits().commit(packageName=PKG, editId=edit_id,
                               changesNotSentForReview=True).execute()
        except HttpError as e:
            if e.resp.status == 400 and 'changesNotSentForReview' in str(
                    e._get_reason()):
                svc.edits().commit(packageName=PKG, editId=edit_id).execute()
            else:
                raise
        print('committed — release is staged on the "%s" track' % TRACK)
    except HttpError as e:
        try:
            svc.edits().delete(packageName=PKG, editId=edit_id).execute()
        except HttpError:
            pass
        print('API ERROR %s:' % e.resp.status, e._get_reason(), file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()

# Food image classifier (Phase 13a)

`assets/foodmodel/food_V1.tflite` + `food_labels.txt` power photo → dish guess →
Free add. The shipped assets live under `assets/foodmodel/`; this folder holds
the provenance + scratch test images (git-ignored).

## Model

**Google AIY Vision — food_V1**, a MobileNet food classifier. **Apache-2.0**,
credited in Settings → About. 2024 dish classes (index 0 = `__background__`),
skewed toward North-American/global dishes.

- Input: `192×192×3` uint8 (feed RGB 0–255 directly).
- Output: `[1, 2024]` uint8; probability = `value / 256`.
- Labels are embedded in the .tflite as a trailing zip (`probability-labels-en.txt`).

The original TF Hub / GCS download is now auth-gated (Kaggle Models). We fetched
the exact same file from a public MIT-licensed mirror:

```sh
curl -L -o food_V1.tflite \
  "https://raw.githubusercontent.com/SilviaSantano/Recognize-Food-With-TensorFlow-Lite/HEAD/app/src/main/ml/lite-model_aiy_vision_classifier_food_V1_1.tflite"
# extract the English labels embedded in the model:
python3 -c "import zipfile;open('food_labels.txt','wb').write(zipfile.ZipFile('food_V1.tflite').read('probability-labels-en.txt'))"
cp food_V1.tflite ../../assets/foodmodel/food_V1.tflite
cp food_labels.txt ../../assets/foodmodel/food_labels.txt
```

## Dart side

`lib/data/ml/food_classifier.dart` (tflite_flutter): resize → uint8 input →
top-K (skip background). `FoodRepository.estimateKcalForLabel` turns the label
into a rough kcal estimate via the local catalog (head-noun fallback, 300 g
plate default). The UI flow is `lib/ui/food/recognize_food_flow.dart`.

Note: `tflite_flutter` ships an inconsistent JVM target; `android/gradle.properties`
sets `kotlin.jvm.target.validation.mode=warning` so the build passes.

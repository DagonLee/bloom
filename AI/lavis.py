from PIL import Image
from flask import Flask, request
import torch
from lavis.models import load_model_and_preprocess
import ssl

ssl._create_default_https_context = ssl._create_unverified_context
app = Flask(__name__)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
# loads BLIP caption base model, with finetuned checkpoints on MSCOCO captioning dataset.
# this also loads the associated image processors
model, vis_processors, _ = load_model_and_preprocess(name="blip_caption", model_type="base_coco", is_eval=True, device=device)

@app.route('/')
def hello():
  return "hello"

@app.route('/predict', methods=['POST'])
def predict():
    if request.method == 'POST':
        file = request.files['file']
        raw_image = Image.open(file).convert("RGB")
        image = vis_processors["eval"](raw_image).unsqueeze(0).to(device)
        return model.generate({"image":image})



if __name__ == '__main__':
    app.run()
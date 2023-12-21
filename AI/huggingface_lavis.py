from PIL import Image
from flask import Flask, request, make_response, jsonify
from transformers import BlipProcessor, BlipForConditionalGeneration
app = Flask(__name__)
processor = BlipProcessor.from_pretrained("Salesforce/blip-image-captioning-large")
model = BlipForConditionalGeneration.from_pretrained("Salesforce/blip-image-captioning-large")
@app.route('/')
def hello():
  return "hello"

@app.route('/predict', methods=['POST'])
def predict():
    if request.method == 'POST':
        file = request.files['file']
        raw_image = Image.open(file).convert('RGB')
        # unconditional image captioning
        inputs = processor(raw_image, return_tensors="pt")
        out = model.generate(**inputs)
        ans = processor.decode(out[0], skip_special_tokens=True)

        return make_response(jsonify({"ans": ans}), 200)

if __name__ == '__main__':
    # app.run(host='0.0.0.0', port=5000) 
    app.run(host='0.0.0.0')
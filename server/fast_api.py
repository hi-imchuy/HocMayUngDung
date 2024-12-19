from flask import Flask, request, jsonify
from flask_cors import CORS
from ultralytics import YOLO
from PIL import Image, ImageDraw
import io
import requests
import cloudinary
import cloudinary.uploader
from collections import Counter

app = Flask(__name__)
CORS(app)

# Cấu hình Cloudinary
cloudinary.config(
    cloud_name="df7mhs6xj",  # Thay bằng tên cloud của bạn
    api_key="247429931397219",        # Thay bằng API Key của bạn
    api_secret="X636Td3W-_ilWARhkXIxqMWNptM"   # Thay bằng API Secret của bạn
)

# Load YOLO model
try:
    model = YOLO("best.pt")  # Thay đường dẫn mô hình nếu cần
except Exception as e:
    raise RuntimeError(f"Error loading YOLO model: {e}")

# Tạo từ điển ánh xạ nhãn với màu sắc
LABEL_COLORS = {
    "hat bi": "green",
    "hat dua": "yellow",
    "hat de cuoi": "orange",
    "hat huong duong": "gold",
    "hat hanh nhan": "brown",
    "hat mac ca": "blue",
    "hat sen": "gray",
    "hat oc cho": "purple",
    "hat dieu": "red",
    "hat dau phong": "pink",
}

@app.route('/xldl', methods=['POST'])
def predict():
    try:
        # Lấy URL ảnh từ body của yêu cầu
        data = request.json  # Lấy dữ liệu JSON từ request
        image_url = data.get('image_url')

        if not image_url:
            return jsonify({"error": "No image URL provided"}), 400

        # Tải ảnh từ URL
        response = requests.get(image_url)
        if response.status_code != 200:
            return jsonify({"error": "Failed to fetch image from URL"}), 400

        # Đọc ảnh từ content
        image = Image.open(io.BytesIO(response.content))

        # Dự đoán bằng YOLO
        results = model(image)

        # Vẽ bounding box và nhãn lên ảnh gốc
        draw = ImageDraw.Draw(image)
        detections = []  # Danh sách lưu nhãn các đối tượng

        if results[0].boxes.data is not None:
            for box in results[0].boxes:
                # Lấy tọa độ bounding box
                bbox = box.xyxy.cpu().numpy()[0]

                # Lấy nhãn của đối tượng
                label = model.names[int(box.cls)]
                detections.append(label)

                # Lấy màu từ LABEL_COLORS hoặc mặc định là "red"
                color = LABEL_COLORS.get(label, "red")

                # Vẽ bounding box và nhãn với màu sắc
                draw.rectangle([bbox[0], bbox[1], bbox[2], bbox[3]], outline=color, width=4)
                draw.text((bbox[0], bbox[1]), label, fill=color, font_size=1)

        # Thống kê số lượng từng loại nhãn
        detection_summary = dict(Counter(detections))

        # Tải ảnh lên Cloudinary
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='JPEG')
        img_byte_arr.seek(0)

        upload_response = cloudinary.uploader.upload(img_byte_arr, resource_type="image")

        # Trả về kết quả dưới dạng JSON
        return jsonify({
            "image": upload_response["secure_url"],
            "detections": detection_summary
        })

    except Exception as e:
        print(f"Error during processing: {e}")
        return jsonify({"error": f"An error occurred: {e}"}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)
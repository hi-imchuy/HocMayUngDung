from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from ultralytics import YOLO
from PIL import Image, ImageDraw
import io
import base64
from collections import Counter

app = FastAPI()

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

@app.post("/xldl")
async def predict(file: UploadFile = File(...)):
    try:
        # Đọc ảnh từ file upload
        content = await file.read()
        image = Image.open(io.BytesIO(content))

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

        # Chuyển ảnh có bounding box thành base64
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='JPEG')
        img_byte_arr.seek(0)
        image_base64 = base64.b64encode(img_byte_arr.getvalue()).decode()

        # Trả về kết quả
        return JSONResponse(content={
            "image": image_base64,
            "detections": detection_summary
        })

    except Exception as e:
        print(f"Error during processing: {e}")
        return JSONResponse(status_code=400, content={"error": f"An error occurred: {e}"})

# if __name__ == '__main__':
#     app.run(debug=False, host='0.0.0.0', port=8888, use_reloader=False)
    # uvicorn fast_api:app --host 0.0.0.0 --port 8000

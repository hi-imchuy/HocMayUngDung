import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart'; // Import Cloudinary SDK

part 'home_event.dart';
part 'home_state.dart';

final cloudinary = Cloudinary("df7mhs6xj", "247429931397219", "X636Td3W-_ilWARhkXIxqMWNptM");

class HomeBloc extends Bloc<HomeEvent, HomeState> {

  final ImagePicker _picker = ImagePicker();
  final Dio dio = Dio();
  final String url = 'http://10.233.1.6:8000/xldl';

  // final String url = 'http://0.0.0.0:8000/xldl';

  // final String url = 'https://hocmayungdung.onrender.com/xldl';

  HomeBloc() : super(HomeInitial()) {
    on<HomeInitialEvent>(homeInitialEvent);
    on<HomeClickAlbumEvent>(homeClickAlbumEvent);
    on<HomeClickCameraEvent>(homeClickCameraEvent);
    on<HomeClickDetectEvent>(homeClickDetectEvent);
  }

  FutureOr<void> homeInitialEvent(HomeInitialEvent event, Emitter<HomeState> emit) {
    emit(HomeInitial());
  }

  Future<void> homeClickAlbumEvent(HomeClickAlbumEvent event, Emitter<HomeState> emit) async {
      try {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          emit(HomeChooseImageFromAlbumSuccess(File(pickedFile.path)));
        } else {
          emit(HomeInitial());
        }
    }catch(e){
      emit(HomeChooseImageFromAlbumFailed());
    }
  }

  Future<void> homeClickCameraEvent(HomeClickCameraEvent event, Emitter<HomeState> emit) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        emit(HomeTakeAPhotoSuccess(File(pickedFile.path)));
      } else {
        emit(HomeInitial());
      }
    }catch(e){
      emit(HomeTakeAPhotoFailed());
    }
  }

  Future<void> homeClickDetectEvent(HomeClickDetectEvent event, Emitter<HomeState> emit) async {
    emit(HomeClickDetectLoading());

    try {
      final file = File(event.image.path); // Chuyển XFile thành File

      // Tạo form data để gửi ảnh
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: 'image.jpg'),
      });

      // Đọc dữ liệu ảnh dưới dạng byte
      List<int> imageBytes = await file.readAsBytes();

      // Tải ảnh lên Cloudinary
      final response_ = await cloudinary.uploadFile(
        fileBytes: imageBytes,
        resourceType: CloudinaryResourceType.Image,  // Đảm bảo là ảnh
        folder: "your_folder_name", // Tùy chọn: Thư mục đích trên Cloudinary
      );

      Map<String, dynamic> bodyData = {
        "image_url": response_.secureUrl,  // Truyền URL của ảnh đã upload lên Cloudinary
      };

      // Gửi ảnh lên server
      Response response = await dio.post(
        url,
        data: bodyData,
        options: Options(responseType: ResponseType.json), // Nhận JSON từ server
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Lấy danh sách phát hiện từ phản hồi
        final Map<String, dynamic> detections = Map<String, dynamic>.from(responseData['detections']);

        // Giải mã ảnh base64 từ phản hồi
        final String base64Image = responseData['image'];
        final Uint8List imageBytes = base64Decode(base64Image);

        // Tạo tên file với timestamp để tránh bị cache
        final directory = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '${directory.path}/image_with_bounding_box_$timestamp.jpg';
        final imageFile = File(filePath)..writeAsBytesSync(imageBytes);

        // Emit state thành công, kèm danh sách phát hiện
        emit(HomeClickDetectSuccess(imageFile, detections));
      } else {
        emit(HomeClickDetectFailed());
      }
    } catch (e) {
      print("Error: $e");
      emit(HomeClickDetectFailed());
    }
  }
}

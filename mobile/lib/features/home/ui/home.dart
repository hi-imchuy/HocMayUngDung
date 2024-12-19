import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xldl_mobile_app/features/home/bloc/home_bloc.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seed Classification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 500,
              width: 500,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 2)),
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: BlocConsumer<HomeBloc, HomeState>(
                listener: (context, state) {
                  if (state is HomeChooseImageFromAlbumSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Upload from album success')));
                  } else if (state is HomeTakeAPhotoSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Take a photo success')));
                  } else if (state is HomeChooseImageFromAlbumFailed) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Upload from album failed')));
                  } else if (state is HomeTakeAPhotoFailed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Take a photo failed')));
                  }
                },
                builder: (context, state) {
                  if (state is HomeChooseImageFromAlbumSuccess) {
                    return Container(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Image.file(state.image));
                  } else if (state is HomeChooseImageFromAlbumFailed) {
                    return const Center(
                      child: Text(
                        "Choose image failed",
                        style: TextStyle(color: Colors.redAccent, fontSize: 20),
                      ),
                    );
                  } else if (state is HomeTakeAPhotoSuccess) {
                    return Image.file(state.image);
                  } else if (state is HomeTakeAPhotoFailed) {
                    return const Center(
                      child: Text(
                        "Take a photo failed",
                        style: TextStyle(color: Colors.redAccent, fontSize: 20),
                      ),
                    );
                  } else if (state is HomeClickDetectSuccess) {
                    return Column(
                      children: [
                        Container(
                          height: 350,
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Image.network(state.imageUrl),
                        ),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.redAccent, width: 2)),
                          margin: const EdgeInsets.fromLTRB(20, 25, 20, 5),
                          child: Scrollbar(
                            thumbVisibility: true,
                            thickness: 10,
                            radius: const Radius.circular(8),
                            child: ListView.builder(
                              itemCount: state.detections.length,
                              itemBuilder: (context, index) {
                                final entry =
                                    state.detections.entries.elementAt(index);

                                final colorMap = {
                                  "hat bi": Colors.green,
                                  "hat dua": Colors.yellow,
                                  "hat de cuoi": Colors.orange,
                                  "hat huong duong": Colors.amber,
                                  "hat hanh nhan": Colors.brown,
                                  "hat mac ca": Colors.blue,
                                  "hat sen": Colors.grey,
                                  "hat oc cho": Colors.purple,
                                  "hat dieu": Colors.red,
                                  "hat dau phong": Colors.pink,
                                };

                                final labelMap = {
                                  "hat bi": 'hạt bí',
                                  "hat dua": 'hạt dưa',
                                  "hat de cuoi": 'hạt dẻ cười',
                                  "hat huong duong": 'hạt hướng dương',
                                  "hat hanh nhan": 'hạt hạnh nhân',
                                  "hat mac ca": 'hạt mắc ca',
                                  "hat sen": 'hạt sen',
                                  "hat oc cho": 'hạt óc chó',
                                  "hat dieu": 'hạt điều',
                                  "hat dau phong": 'hạt đậu phộng',
                                };

                                final color =
                                    colorMap[entry.key] ?? Colors.black;
                                final String label =
                                    labelMap[entry.key] ?? 'Invalid';

                                return ListTile(
                                  title: Text(
                                    "$label: ${entry.value}",
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    );
                  } else if (state is HomeClickDetectLoading) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: 2,
                          child: const CircularProgressIndicator(
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          "Detecting your image",
                          style: TextStyle(fontSize: 20, color: Colors.red),
                        )
                      ],
                    );
                  } else if (state is HomeClickDetectFailed) {
                    return const Center(
                      child: Text(
                        "Detect Failed",
                        style: TextStyle(color: Colors.redAccent, fontSize: 20),
                      ),
                    );
                  } else if (state is HomeInitial) {
                    return const Center(
                      child: Text(
                        "No image have been selected",
                        style: TextStyle(color: Colors.redAccent, fontSize: 18),
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    height: 50,
                    width: 170,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(HomeClickCameraEvent());
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.redAccent),
                          Text(
                            'Take a photo',
                            style: TextStyle(fontSize: 13, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 170,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(HomeClickAlbumEvent());
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.photo, color: Colors.redAccent),
                          Text(
                            'Album',
                            style: TextStyle(fontSize: 13, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              height: 60,
              width: 200,
              child: BlocConsumer<HomeBloc, HomeState>(
                listener: (context, state) {
                  if (state is HomeClickDetectFailed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Detect Fail')));
                  } else if (state is HomeClickDetectSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Detect Success')));
                  }
                },
                builder: (context, state) {
                  if (state is HomeChooseImageFromAlbumSuccess) {
                    return ElevatedButton(
                      onPressed: () {
                        showDialog(context: context, builder: (BuildContext context){
                          return AlertDialog(
                            title: Text("Select Model"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(title: Text('YoloV8'),
                                onTap: (){
                                  print("Huy Yolo");
                                  context.read<HomeBloc>().add(HomeClickDetectEvent(state.image));
                                  Navigator.pop(context);
                                },),
                                ListTile(title: Text('MobilenetV2'),
                                  onTap: (){
                                    print("Huy MobileNet");
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'START DETECT!',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    );
                  } else if (state is HomeTakeAPhotoSuccess) {
                    return ElevatedButton(
                      onPressed: () {
                        context
                            .read<HomeBloc>()
                            .add(HomeClickDetectEvent(state.image));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'START DETECT!',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    );
                  }
                  return ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please choose or take a photo')));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'START DETECT!',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:io';
//
// import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:split/theme/colors.dart';
// import 'package:split/utils/app_font.dart';
// import 'package:split/utils/assets.dart';
// import 'package:split/utils/string.dart';
// import 'package:split/utils/utils.dart';
//
// class PdfViewerScreen extends StatefulWidget {
//   final File? path;
//
//   const PdfViewerScreen({super.key, this.path});
//
//   @override
//   State<PdfViewerScreen> createState() => _PdfViewerScreenState();
// }
//
// class _PdfViewerScreenState extends State<PdfViewerScreen> {
//   PDFDocument? document;
//
//   Future<void> fetchPdfData() async {
//     try {
//       final file = File("${widget.path!.path}");
//
//       if (await file.exists()) {
//         final doc = await PDFDocument.fromFile(file);
//         setState(() {
//           document = doc;
//         });
//       } else {
//         print('File does not exist: ${widget.path}');
//       }
//     } catch (e) {
//       print('Error reading PDF: $e');
//     }
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     fetchPdfData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         centerTitle: false,
//         elevation: 1.5,
//         shadowColor: AppColors.txtGrey.withOpacity(0.2),
//         backgroundColor: AppColors.white,
//         leading: GestureDetector(
//           onTap: () {
//             Get.back();
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(15.0),
//             child: SvgPicture.asset(
//               AppIcons.back_icon,
//             ),
//           ),
//         ),
//         titleSpacing: 0,
//         title: Text(ConstString.invoice,
//             style: Theme.of(context)
//                 .textTheme
//                 .titleLarge!
//                 .copyWith(fontFamily: AppFont.fontBold, fontSize: 18)),
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () {
//               Share.shareFiles([widget.path!.path],
//                   text: 'Split Group Transactions');
//             },
//           ),
//         ],
//       ),
//       body: document == null
//           ? Center(
//               child: CupertinoActivityIndicator(
//                 color: AppColors.darkPrimaryColor,
//                 radius: 12,
//               ),
//             )
//           : PDFViewer(
//               document: document!,
//               backgroundColor: AppColors.white,
//               showIndicator: false,
//               zoomSteps: 0,
//               minScale: 2,
//               maxScale: 2,
//             ),
//     );
//   }
// }

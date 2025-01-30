// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:split/controller/expense_controller.dart';
import 'package:split/controller/group_controller.dart';
import 'package:split/controller/user_controller.dart';
import 'package:split/custom_group_avtar_widget.dart';
import 'package:split/model/expense_data.dart';
import 'package:split/model/group_data.dart';
import 'package:split/model/group_members.dart';
import 'package:split/model/user_contact_model.dart';
import 'package:split/model/usermodel.dart';
import 'package:split/screen/split_screen.dart';
import 'package:split/theme/colors.dart';
import 'package:split/utils/app_font.dart';
import 'package:split/utils/assets.dart';
import 'package:split/utils/string.dart';
import 'package:split/utils/utils.dart';

class ExpenseForm extends StatelessWidget {
  Expense? expense;

  ExpenseForm({Key? key, this.selectedGroup, this.expense}) : super(key: key) {
    final ExpenseController controller = Get.put(ExpenseController());
    controller.setExpense(expense);
  }

  final GroupDataModel? selectedGroup;

  final ExpenseController controller = Get.put(ExpenseController());
  final GroupController groupController = Get.find<GroupController>();
  static bool isControllerInitialized = false;

  @override
  Widget build(BuildContext context) {
    List<GroupMember> memberModels = selectedGroup?.memberIds?.toList() ?? [];
    List<ContactModel?> groupMembers = groupController.getContactNamesByNumbers(
        memberModels
            .where((element) => element.user.mobileNo != null)
            .map((e) => e.user.mobileNo!)
            .toList());

    // if (expense != null ) {
    //   controller.expenseDescriptionController.text = expense?.title ?? "";
    //   controller.expenseAmountController.text =
    //       expense!.amount!.round().toString() ?? "0.0";
    //   controller.selectedPaidUser.value = expense?.payerId;
    //   controller.selectedFormateDate.value = DateFormat('dd MMMM yyyy')
    //       .format(expense?.createdAt ?? DateTime.now());
    //   isControllerInitialized = true;
    // }

    return WillPopScope(
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          elevation: 1,
          shadowColor: AppColors.decsGrey.withOpacity(0.5),
          backgroundColor: AppColors.white,
          centerTitle: false,
          leading: GestureDetector(
            onTap: () {
              controller.expenseDescriptionController.clear();
              controller.expenseAmountController.clear();
              controller.selectedPaidUser.value = null;
              controller.selectedPaidContact.value = null;
              Get.back();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SvgPicture.asset(
                AppIcons.back_icon,
              ),
            ),
          ),
          titleSpacing: -10,
          title: Row(
            children: [
              selectedGroup!.groupProfile != null &&
                  selectedGroup!.groupProfile!.isNotEmpty
                  ? ClipOval(
                child: CachedNetworkImage(
                  height: 35,
                  width: 35,
                  imageUrl: selectedGroup!.groupProfile! ?? "",
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                  progressIndicatorBuilder:
                      (context, url, downloadProgress) => SizedBox(
                    width: 30,
                    height: 30,
                    child: Center(
                        child: LoadingIndicator(
                          colors: [AppColors.primaryColor],
                          indicatorType: Indicator.ballScale,
                          strokeWidth: 1,
                        )),
                  ),
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                  color: AppColors.darkPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SvgPicture.asset(AppImages.split_logo),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                selectedGroup!.name ?? "Group",
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontFamily: AppFont.fontSemiBold, fontSize: 16),
              ),
            ],
          ),
        ),
        body: expenseFormWidget(context, memberModels, groupMembers),
      ),
      onWillPop: () async {
        controller.expenseDescriptionController.clear();
        controller.expenseAmountController.clear();
        controller.selectedPaidUser.value = null;
        controller.selectedPaidContact.value = null;
        return true;
      },
    );
  }

  Widget expenseFormWidget(BuildContext context, List<GroupMember> memberIds,
      List<ContactModel?> groupMembers) {
    List<DropdownMenuItem<GroupMember>> dropdownItems = selectedGroup!
        .memberIds!
        .where((groupMember) => groupMember.status == 'active')
        .map((GroupMember groupMember) {
      return DropdownMenuItem<GroupMember>(
        value: groupMember, // Use a unique identifier like groupMember.user.id
        child: Text(
          getUserName(groupMember.user),
          textScaler: const TextScaler.linear(1),
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: 13,
                color: AppColors.darkPrimaryColor,
              ),
        ),
      );
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ConstString.enterDescription,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: AppColors.darkPrimaryColor, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: SizedBox(
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1)),
                  child: TextFormField(
                    // maxLines: 3,
                    textCapitalization: TextCapitalization.words,
                    controller: controller.expenseDescriptionController,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.darkPrimaryColor, fontSize: 14),
                    cursorColor: AppColors.txtGrey,
                    decoration: InputDecoration(
                        hintText: "Enter Description",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: AppColors.txtGrey, fontSize: 13.5),
                        fillColor: AppColors.decsGrey,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(color: AppColors.decsGrey)),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20)),
                  )),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ConstString.enterAmount,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: AppColors.darkPrimaryColor, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: SizedBox(
              height: 60,
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1)),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.number,
                    controller: controller.expenseAmountController,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.darkPrimaryColor, fontSize: 14),
                    cursorColor: AppColors.txtGrey,
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: SvgPicture.asset(AppIcons.dollerIcon),
                        ),
                        hintText: "Enter Amount",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: AppColors.txtGrey, fontSize: 13.5),
                        fillColor: AppColors.decsGrey,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide(color: AppColors.decsGrey)),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20)),
                  )),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ConstString.paidByYou,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: AppColors.darkPrimaryColor, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                  color: AppColors.decsGrey,
                  borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                            items: dropdownItems,
                            value: controller.selectedPaidContact.value,
                            onChanged: (GroupMember? value) {
                              controller.selectContact(
                                  GroupMember(user: value!.user), memberIds);
                            },
                            isExpanded: true,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                    color: AppColors.darkPrimaryColor,
                                    fontSize: 15),
                            hint: Row(
                              children: [
                                SvgPicture.asset(AppIcons.profileIcon,
                                    height: 20,
                                    color: AppColors.darkPrimaryColor),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Select Paid User",
                                  textScaler: const TextScaler.linear(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(fontSize: 14),
                                ),
                              ],
                            ),
                            dropdownStyleData: DropdownStyleData(
                                width: 310,
                                maxHeight: 200,
                                useSafeArea: true,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15)),
                                scrollbarTheme: ScrollbarThemeData(
                                    thickness: MaterialStateProperty.all(3),
                                    crossAxisMargin: 1,
                                    // showTrackOnHover: true,
                                    radius: Radius.circular(20),
                                    thumbColor: MaterialStateProperty.all(
                                        AppColors.txtGrey.withOpacity(0.2)),
                                    interactive: true)),
                          )),
                        )),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ConstString.date,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: AppColors.darkPrimaryColor, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: SizedBox(
              height: 60,
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1)),
                  child: TextFormField(
                    textCapitalization: TextCapitalization.words,
                    controller: controller.dateController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          currentDate: DateTime.now(),
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: AppColors.darkPrimaryColor,
                                hintColor:
                                    AppColors.darkPrimaryColor.withOpacity(0.6),
                                datePickerTheme: DatePickerThemeData(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    dayStyle:
                                        Theme.of(context).textTheme.titleSmall,
                                    weekdayStyle:
                                        Theme.of(context).textTheme.titleSmall,
                                    headerHelpStyle:
                                        Theme.of(context).textTheme.titleMedium,
                                    headerHeadlineStyle:
                                        Theme.of(context).textTheme.titleSmall,
                                    yearStyle:
                                        Theme.of(context).textTheme.titleMedium,
                                    dividerColor:
                                        AppColors.lightGrey.withOpacity(0.3),
                                    surfaceTintColor: AppColors.white),
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.darkPrimaryColor,
                                  onPrimary: AppColors.white,
                                  onSurface: AppColors.darkPrimaryColor,
                                  secondary: AppColors.darkPrimaryColor,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors
                                        .darkPrimaryColor, // button text color
                                  ),
                                ),
                                textTheme: TextTheme(
                                  titleMedium:
                                      Theme.of(context).textTheme.titleMedium,
                                  labelLarge:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              child: child!,
                            );
                          });

                      if (pickedDate != null) {
                        controller.selectedDate = pickedDate;
                        print("Selected Data : ${controller.selectedDate}");
                        controller.selectedDateTime = DateTime.now();
                        controller.selectedFormateDate.value =
                            DateFormat('dd MMMM yyyy')
                                .format(controller.selectedDate!);
                        controller.dateController.text =
                            controller.selectedFormateDate.value;
                      }
                    },
                    // controller: controller.addController,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.darkPrimaryColor, fontSize: 14),
                    cursorColor: AppColors.txtGrey,
                    decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10),
                          child: SizedBox(
                              height: 10,
                              child: SvgPicture.asset(
                                AppIcons.calenderIcon,
                              )),
                        ),
                        hintText: "Select Date",
                        hintStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: AppColors.txtGrey, fontSize: 13.5),
                        fillColor: AppColors.decsGrey,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: BorderSide(color: AppColors.decsGrey)),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppColors.decsGrey, width: 1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20)),
                  )),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                //   groupController.selectGroup(selectedGroup!);
                if (controller.validateData(context)) {
                  if (double.parse(controller.expenseAmountController.text) >
                      0) {
                    controller.addFormDataToExpense(selectedGroup!);
                    if (expense != null) {
                      Get.to(() => SplitScreen(
                            editAmout: controller.expenseAmountController.text,
                            expense: expense,
                            groupData: selectedGroup,
                          ));
                    } else {
                      Get.to(() => SplitScreen(
                            groupData: selectedGroup,
                          ));
                    }
                  } else {
                    showInSnackBar(
                        context, "Please enter valid expense amount");
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  fixedSize: const Size(200, 50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: Text(
                expense != null ? ConstString.edit : ConstString.next,
                textScaler: const TextScaler.linear(1),
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: AppColors.darkPrimaryColor,
                    fontFamily: AppFont.fontMedium),
              )),
          SizedBox(
            height: 70,
          )
        ],
      ),
    );
  }

  String getUserName(UserModel? user) {
    UserController userController = Get.find<UserController>();

    return userController.getNameByPhoneNumber(user?.mobileNo) ??
        user?.name ??
        "Split User";
  }
}

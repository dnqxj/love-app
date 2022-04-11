import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:new_app/base/view.dart';
import 'package:new_app/eventbus/event_bus.dart';
import 'package:new_app/utils/data_utils.dart';
import 'package:new_app/viewmodel/register_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:weui/button/index.dart';
import 'package:weui/cell/index.dart';
import 'package:weui/dialog/index.dart';
import 'package:weui/form/index.dart';
import 'package:weui/input/index.dart';
import 'package:weui/switch/index.dart';
import 'package:weui/toast/index.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  TextEditingController _user;
  TextEditingController _pass;
  TextEditingController _phone;
  TextEditingController _code;
  TextEditingController _name;

  DateTime _dateTime;
  int _gender = 0; // 0=男;1=女
  int _solar = 0; // 0=阳历;1=公历
  int count=0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _user = TextEditingController();
    _pass = TextEditingController();
    _phone = TextEditingController();
    _code = TextEditingController();
    _name = TextEditingController();
    bus.on("fail", (arg) {  // 订阅消息，来自viewmodel层
      if (arg["view"] == "register") {
        WeToast.fail(context)(message: arg["message"]);
      }
    });
    bus.on("alert", (arg) {  // 订阅消息，来自viewmodel层
      if (arg["view"] == "register") {
        WeDialog.alert(context)(arg["message"]);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _user.dispose();
    _pass.dispose();
    _phone.dispose();
    _code.dispose();
    _name.dispose();
    bus.off("fail");
    bus.off("alert");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar("注册"),
      body: WeForm(
        children: [
          WeInput(
            label: "登录账号",
            hintText: "请输入登录用户名",
            clearable: true,
            textInputAction: TextInputAction.next,
            onChange: (v) {
              _user.text = v;
            },
          ),
          WeInput(
            label: "手机号",
            hintText: "请输入手机号码",
            textInputAction: TextInputAction.send,
            type: TextInputType.phone,
            onChange: (v) {
              _phone.text = v;
            },
            footer: WeButton(
              count > 0 ? count.toString() + "秒后再次获取" : "获取验证码",
              theme: WeButtonType.primary,
              size: WeButtonSize.mini,
              disabled: count > 0 ? true : false,
              onClick: _getCode,
            ),
          ),
          WeInput(
            label: "验证码",
            hintText: "请输入验证码",
            textInputAction: TextInputAction.next,
            type: TextInputType.number,
            clearable: true,
            onChange: (v) {
              _code.text = v;
            },
          ),
          WeInput(
            label: "登录密码",
            hintText: "请输入登录密码",
            textInputAction: TextInputAction.next,
            clearable: true,
            obscureText: true,
            onChange: (v) {
              _pass.text = v;
            },
          ),
          WeInput(
            label: "中文姓名",
            hintText: "请输入中文姓名",
            textInputAction: TextInputAction.next,
            obscureText: true,
            onChange: (v) {
              _name.text = v;
            },
            footer: Row(
              children: [
                WeSwitch(
                  size: 20,
                  checked: _gender == 0 ? true : false,
                  onChange: (v) {
                    setState(() {
                      _gender = v ? 1 : 0;
                    });
                  },
                ),
                SizedBox(width: 8,),
                Text(
                    _gender == 0 ? '男' : '女'
                ),
              ],
            )
          ),
          WeCell(
            label: "出生日期",
            content: getYMD(_dateTime),
            align: Alignment.center,
            footer: Row(
              children: [
                WeSwitch(
                  size: 20,
                  checked: _solar == 0 ? true : false,
                  onChange: (v) {
                    setState(() {
                      _solar = v ? 1 : 0;
                    });
                  },
                ),
                SizedBox(width: 8,),
                Text(
                  _solar == 0 ? "阳历" : "阴历",
                ),
              ],
            ),
            onClick: () async {
              DatePicker.showDatePicker(context,
                showTitleActions: true,
                minTime: DateTime(1980, 1, 1),
                maxTime: DateTime(2022, 1, 1),
                onChanged: (date) {
                  print('change $date');
                },
                onConfirm: (date) {
                  print('confirm $date');
                  setState(() {
                    _dateTime = date;
                  });
                },
                currentTime: DateTime.now(),
                locale: LocaleType.zh
              );
            },
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: WeButton(
              "注册",
              theme: WeButtonType.primary,
              loading: Provider.of<RegisterViewmodel>(context).getLoading,
              onClick: _register,
            ),
          )
        ],
      ),
    );
  }

  void _getCode() {
    setState(() {
      count = 60;
    });
    _task();
  }

  void _task() {
    Future.delayed(new Duration(seconds: 1), () {
      setState(() {
        count--;
        if (count > 0) {
          _task();
        }
      });
    });
  }

  void _register() {
      if (_user.text == null || _user.text.isEmpty) {
        WeToast.fail(context)(message: "账号不能为空~");
        return;
      }

      if (_phone.text == null || _phone.text.isEmpty) {
        WeToast.fail(context)(message: "手机号不能为空~");
        return;
      }
      if (_code.text == null || _code.text.isEmpty) {
        WeToast.fail(context)(message: "验证码不能为空~");
        return;
      }
      if (_pass.text == null || _pass.text.isEmpty) {
        WeToast.fail(context)(message: "密码不能为空~");
        return;
      }
      if (_name.text == null || _name.text.isEmpty) {
        WeToast.fail(context)(message: "姓名不能为空~");
        return;
      }

      if (_dateTime == null) {
        WeToast.fail(context)(message: "生日不能为空~");
        return;
      }
      context.read<RegisterViewmodel>().login(
        _user.text,
        _pass.text,
        _name.text,
        _phone.text,
        _code.text,
        _gender,
        getYMD(_dateTime),
        _solar
      );
    }
}

/**
 * @discripe: 弹幕 & 礼物
 */
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../base.dart';
import 'animate.dart' show Gift;

class ChatWidgets extends StatefulWidget {
  @override
  _ChatWidgets createState() => _ChatWidgets();
}

class _ChatWidgets extends State<ChatWidgets> with DYBase {
  List msgData = [];  // 弹幕消息列表
  List<Map> giftBannerView = [];  // 礼物横幅列表JSON

  // Timer giftTimer;  // 礼物横幅模拟每s循环出现动画
  // Timer msgTimer;  // 弹幕消息模拟200ms收到弹幕

  ScrollController _chatController = ScrollController();  // 弹幕区滚动Controller

  @override
  void initState() {
    super.initState();
    SocketClient.create();
    var channel = SocketClient.channel;
    // 接受弹幕消息
    channel.stream.listen((message) {
      message = json.decode(message);
      var sign = message[0];
      var data = message[1];
      if (sign == 'getChat') {
        print(data);
        setState(() {
          msgData.add(data);
        });
        _chatController.jumpTo(_chatController.position.maxScrollExtent);
      } else if (sign == 'getGift') {
        print(data);
        var now = DateTime.now();
        var obj = {
          'stamp': now.millisecondsSinceEpoch,
          'config': data
        };
        Gift.add(giftBannerView, obj, 6500, (giftBannerViewNew) {
          setState(() {
            giftBannerView = giftBannerViewNew;
          });
        });
      }
    });

    channel.sink.add('getChat');
    channel.sink.add('getGift');

    // 接受礼物消息
    /* channel.stream.listen((message) {
      if (message == 'getGift') {
        message = json.decode(message);
        print(message);
        /* var now = DateTime.now();
        var obj = {
          'stamp': now.millisecondsSinceEpoch,
          'config': message
        };
        Gift.add(giftBannerView, obj, 6500, (giftBannerViewNew) {
          setState(() {
            giftBannerView = giftBannerViewNew;
          });
        }); */
      }
    });

    channel.sink.add('getGift'); */

    // 请求弹幕数据，模拟弹幕消息 (已废弃，现改为webSocket接受服务端推送消息)
    /* httpClient.post('/dy/flutter/msgData').then((res) {
      var msgDataSource = res.data['data'];
      var i = 0;
      msgTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
        if (i > 60) {
          _chatController.jumpTo(_chatController.position.maxScrollExtent);
          msgTimer.cancel();
          return;
        }
        setState(() {
          msgData.add(msgDataSource[Random().nextInt(msgDataSource.length)]);
        });
        _chatController.jumpTo(_chatController.position.maxScrollExtent);
        i++;
      });
    }); */
    // 请求礼物横幅数据，模拟礼物赠送动画 (已废弃，现改为webSocket接受服务端推送消息)
    /* httpClient.get('/dy/flutter/giftData').then((res) {
      var giftData = res.data['data'];
      giftTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (giftTimer.tick > giftData.length) {
          giftTimer.cancel();
          return;
        }
        var now = DateTime.now();
        var json = {
          'stamp': now.millisecondsSinceEpoch,
          'config': giftData[giftTimer.tick - 1]
        };
        Gift.add(giftBannerView, json, 6500, (giftBannerViewNew) {
          setState(() {
            giftBannerView = giftBannerViewNew;
          });
        });
      });
    }); */
  }

  @override
  void dispose() {
    SocketClient.channel?.sink?.close(status.goingAway);
    // giftTimer?.cancel();
    // msgTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: DYBase.dessignWidth)..init(context);

    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xffeeeeee), width: dp(1)),
            bottom: BorderSide(color: Color(0xffeeeeee), width: dp(1))
          ),
        ),
        child: Stack(
          children: <Widget>[
            ListView(
              controller: _chatController,
              padding: EdgeInsets.all(dp(10)),
              children: _chatMsg(),
            ),
            ..._setGiftBannerView(),
          ],
        ),
      ),
    );
  }

  List<Widget> _chatMsg() {
    var msgList = List<Widget>();

    msgData.forEach((item) {
      var isAdmin = item['lv'] > 0;
      var msgBoart = <Widget>[
        RichText(
          text: TextSpan(
            style: TextStyle(color: Color(0xff666666), fontSize: 16.0),
            children: [
              TextSpan(
                text: '''${isAdmin ? '''          ''' : ''}${item['name']}: ''',
                style: TextStyle(
                  color: !isAdmin ? Colors.red : Color(0xff999999)
                ),
              ),
              TextSpan(
                text: item['text'],
              ),
            ]
          ),       
        ),
      ];

      if (item['lv'] > 0) {
        msgBoart.insert(0, Positioned(
          child: Image.asset(
            'images/lv/${item['lv']}.png',
            height: dp(18),
          ),
        ));
      }

      msgList.addAll([
        Stack(
          children: msgBoart,
        ),
        Padding(padding: EdgeInsets.only(bottom: dp(5)))
      ]);
    });

    return msgList;
  }

  List<Widget> _setGiftBannerView() {
    List banner = <Widget>[];

    giftBannerView.forEach((item) {
      banner.add(item['widget']);
    });
    return banner;
  }

}
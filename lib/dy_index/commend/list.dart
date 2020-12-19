/*
 * @discripe: 正在直播列表
 */
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../base.dart';

class LiveListWidgets extends StatelessWidget with DYBase {
  final indexState;
  LiveListWidgets(this.indexState);

  // 跳转直播间
  void _goToLiveRoom(context, item) {
    Navigator.pushNamed(context, '/room', arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: DYBase.dessignWidth)..init(context);
    List liveData = indexState['liveData'];

    return Container(
      color: Color(0xfff1f5f6),
      child: Column(
        children: <Widget>[
          _listTableHeader(),
          _listTableInfo(context, liveData),
        ]
      ),
    );
  }

  // 直播列表头部
  Widget _listTableHeader() {
    return Padding(
      padding: EdgeInsets.only(left: dp(6), right: dp(6)),
      child: Row(
        children: <Widget>[
          Container(
            width: dp(20),
            height: dp(30),
            margin: EdgeInsets.only(right: dp(5)),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/isLive.png'),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Expanded(
            child: Text('正在直播'),
          ),
          Row(
            children: <Widget>[
              Text('当前',
                style: TextStyle(
                  color: Color(0xff999999),
                ),
              ),
              Text('12345',
                style: TextStyle(
                  color: Color(0xffff7700),
                ),
              ),
              Text('个直播',
                style: TextStyle(
                  color: Color(0xff999999),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: dp(5)),
                child: Image.asset(
                  'images/next.png',
                  height: dp(14),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _renderTag(showKingTag) {
    if (showKingTag) {
      return [
        Container(
          height: dp(18),
          decoration: BoxDecoration(
            color: Color(0xfffcf0e2),
            borderRadius: BorderRadius.all(
              Radius.circular(9),
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(
                left: dp(6), right: dp(6),
              ),
              child: Text(
                '皇帝推荐',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: dp(10),
                  color: Color(0xfff7802c),
                ),
              ),
            ),
          ),
        ),
      ];
    }
    return [
      Container(
        height: dp(18),
        margin: EdgeInsets.only(right: dp(2)),
        child: Text(
          '颜值',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: dp(12),
            color: Color(0xffa2a2a2),
          ),
        ),
      ),
      Image.asset(
        'images/dg.webp',
        height: dp(7),
      ),
    ];
  }

  // 直播列表详情
  Widget _listTableInfo(context, liveData) {
    final liveList = List<Widget>();
    var fontStyle = TextStyle(
      color: Colors.white,
      fontSize: 12.0
    );
    var boxWidth = dp(164);
    var imageHeight = dp(98);
    var boxMargin = (dp(375) - boxWidth * 2) / 3 / 2;

    liveData.asMap().keys.forEach((index) {
      var item = liveData[index];
      var showKingTag = index % 5 == 0;
      liveList.add(
        GestureDetector(
          onTap: () {
            _goToLiveRoom(context, item);
          },
          child: Padding(
          key: ObjectKey(item['rid']),
          padding: EdgeInsets.all(boxMargin),
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(dp(10)),
              ),
              child: Container(
                width: boxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: item['roomSrc'],
                      imageBuilder: (context, imageProvider) => Container(
                        height: imageHeight,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              child: Container(
                                width: dp(120),
                                height: dp(18),
                                padding: EdgeInsets.only(right: dp(6)),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(-.4, 0.0),
                                    end: Alignment(1, 0.0),
                                    colors: <Color>[
                                      Color.fromRGBO(0, 0, 0, 0),
                                      Color.fromRGBO(0, 0, 0, .6),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Image.asset(
                                      'images/hot.png',
                                      height: dp(14),
                                    ),
                                    Padding(padding: EdgeInsets.only(right: dp(3))),
                                    Text(
                                      item['hn'],
                                      style: fontStyle,
                                    ),
                                  ],
                                ),
                              ),
                              top: 0,
                              right: 0,
                            ),
                            Positioned(
                              child: Container(
                                width: boxWidth,
                                height: dp(25),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(0, -.5),
                                    end: Alignment(0, 1.3),
                                    colors: <Color>[
                                      Color.fromRGBO(0, 0, 0, 0),
                                      Color.fromRGBO(0, 0, 0, .6),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: dp(6),
                                        top: dp(4)
                                      ),
                                      child:  Image.asset(
                                        'images/member.png',
                                        height: dp(12),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(right: dp(3))),
                                    Text(
                                      item['nickname'],
                                      style: fontStyle,
                                    ),
                                  ],
                                ),
                              ),
                              bottom: 0,
                              left: 0,
                            ),
                          ],
                        ),
                      ),
                      placeholder: (context, url) => Image.asset(
                        'images/pic-default.jpg',
                        height: imageHeight,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          SizedBox(
                            height: dp(27),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: dp(6), right: dp(6)),
                                  width: boxWidth,
                                  child: Text(
                                    item['roomName'],
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: dp(13),
                                    ),
                                  ),
                                )
                              ]
                            ),
                          ),
                          Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: [
                               Container(
                                margin: EdgeInsets.only(right: dp(6.0 + 20)),
                                padding: EdgeInsets.only(left: dp(6)),
                                height: dp(18),
                                child: Row(
                                  children: [
                                    ..._renderTag(showKingTag),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: dp(6),
                                child: Image.asset(
                                  'images/dg0.webp',
                                  height: dp(3),
                                ),
                              )
                            ]
                          ),
                          Padding(padding: EdgeInsets.only(bottom: dp(7.5),))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      );
    });

    return Wrap(
      children: liveList,
    );
  }

}
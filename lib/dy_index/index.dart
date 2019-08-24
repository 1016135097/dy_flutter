/**
 * @discripe: 首页轮播图、视频列表、底部导航更多功能
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import '../bloc.dart';
import '../base.dart';
import 'funny.dart';
import 'focus.dart';

class DyIndexPage extends StatefulWidget {
  final arguments;
  DyIndexPage({Key key, this.arguments}) : super(key: key);

  @override
  _DyIndexPageState createState() => _DyIndexPageState();
}

class _DyIndexPageState extends State<DyIndexPage> with DYBase, SingleTickerProviderStateMixin {
  final _bottomNavList = ["推荐", "娱乐", "关注", "鱼吧", "发现"]; // 底部导航
  final swiperController = SwiperController();

  int _currentIndex = 0;  // 底部导航当前页面
  List _navList;  // 推荐标题列表
  List swiperPic = [];  // 轮播图地址
  List liveData = []; // 推荐直播间列表

  @override
  void initState() {
    super.initState();
    // 优先从缓存中拿navList
    DYio.getTempFile('_navList').then((dynamic data) {
      if (data == null) return;
      setState(() {
        _navList = data['data'];
        _getLiveData(_navList[0]);
      });
    });
    _getNav();
    _getSwiperPic();
  }

  // 获取导航列表
  void _getNav() {
    DYhttp.get(
      '/dy/flutter/nav',
      cacheName: '_navList',
    ).then((res) {
      setState(() {
        _navList = res['data'];
      });
      _getLiveData(_navList[0]);
    });
  }
  // 获取轮播图数据
  void _getSwiperPic() {
    DYhttp.post('/dy/flutter/swiper').then((res) {
      setState(() {
        swiperPic = res['data']; 
      });
    });
  }
  // 获取正在直播列表数据
  void _getLiveData(String i) {
    DYhttp.post(
      '/dy/flutter/liveData',
      param: {
        'typeName': i
      }
    ).then((res) {
      setState(() {
       liveData = res['data']; 
      });
    });
  }

  /*---- 事件对应方法 ----*/
  // 点击悬浮标
  void _incrementCounter() {
    final counterBloc = BlocProvider.of<CounterBloc>(context);
    counterBloc.dispatch(CounterEvent.increment);
  }
  // 跳转直播间
  void _goToLiveRoom(item) {
    Navigator.pushNamed(context, '/room', arguments: item);
  }

  /*---- 部件buid函数入口 ----*/
  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: DYBase.dessignWidth)..init(context);
    final tabBloc = BlocProvider.of<TabBloc>(context);
    return Scaffold(
      // 底部导航栏
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: DYBase.defaultColor,
        unselectedItemColor: Colors.black38,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        onTap: (index) {
          tabBloc.dispatch(UpdateTab(_navList));
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              title: Text(_bottomNavList[0]),
              icon: _currentIndex == 0
                  ? Icon(Icons.done_all)
                  : Icon(Icons.done)),
          BottomNavigationBarItem(
              title: Text(_bottomNavList[1]),
              icon: _currentIndex == 1
                  ? Icon(Icons.flight_takeoff)
                  : Icon(Icons.flight_land)),
          BottomNavigationBarItem(
              title: Text(_bottomNavList[2]),
              icon: _currentIndex == 2
                  ? Icon(Icons.hourglass_full)
                  : Icon(Icons.hourglass_empty)),
          BottomNavigationBarItem(
              title: Text(_bottomNavList[3]),
              icon: _currentIndex == 3
                  ? Icon(Icons.trending_up)
                  : Icon(Icons.trending_down)),
          BottomNavigationBarItem(
              title: Text(_bottomNavList[4]),
              icon: _currentIndex == 4
                  ? Icon(Icons.thumb_up)
                  : Icon(Icons.thumb_down)),
        ]
      ),
      body: _currentPage(),
      floatingActionButton: _currentIndex != 0 ? null : FloatingActionButton(
        onPressed: _incrementCounter,
        foregroundColor: DYBase.defaultColor,
        backgroundColor: Colors.white,
        tooltip: 'Increment',
        child: Icon(Icons.favorite),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  // 底部导航对应的页面
  Widget _currentPage() {
    Widget page;
    switch (_currentIndex) {
      case 0:
        page = BlocBuilder<CounterBloc, int>(
          builder: (BuildContext context, int count) {
            return Scaffold(
              body: _navList == null ? null : DefaultTabController(
                length: _navList.length,
                child: NestedScrollView(  // 嵌套式滚动视图
                  headerSliverBuilder: (context, innerScrolled) => <Widget>[
                    // 滑动折叠头部
                    SliverOverlapAbsorber(
                      // 传入 handle 值，直接通过 `sliverOverlapAbsorberHandleFor` 获取即可
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      child: SliverAppBar(
                        backgroundColor: Colors.white,
                        brightness: Brightness.light,
                        textTheme: TextTheme(
                          title: TextStyle(
                            color: DYBase.defaultColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        pinned: true,
                        actions: <Widget>[
                          _header()
                        ],
                        expandedHeight: dp(140),
                        flexibleSpace: FlexibleSpaceBar(  // 下拉渐入背景
                          background: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.0, 1),
                                end: Alignment(0.0, -0.7),
                                colors: <Color>[
                                  Color(0xffffffff),
                                  Color(0xffff9b7a)
                                ],
                              ),
                            ),
                          ),
                        ),
                        bottom: TabBar(
                          isScrollable: true,
                          labelStyle: TextStyle(fontSize: 15),
                          labelColor: DYBase.defaultColor,
                          indicatorColor: DYBase.defaultColor,
                          unselectedLabelColor: Color(0xff333333),
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: _navList.map((e) => Tab(text: e)).toList()
                        ),
                        forceElevated: innerScrolled,
                      ),
                    )
                  ],
                  body: TabBarView(
                    // 这边需要通过 Builder 来创建 TabBarView 的内容，否则会报错
                    // NestedScrollView.sliverOverlapAbsorberHandleFor必须在NestedScrollView中调用
                    children: _navList.asMap().map((i, tab) => MapEntry(i, Builder(
                        builder: (context) => CustomScrollView(
                          key: PageStorageKey<String>(tab),
                          slivers: <Widget>[
                            // 将子部件同 `SliverAppBar` 重叠部分顶出来，否则会被遮挡
                            SliverOverlapInjector(
                                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
                            SliverToBoxAdapter(
                              child: Container(
                                child: i == 0 ? Column(
                                  children: [
                                    _swiper(),
                                    _liveTable(count),
                                  ],
                                ) : null,
                              ),
                            )
                          ],
                        ),
                      ),),
                    ).values.toList(),
                  ),
                ),
              ),
            );
          },
        );
        break;
      case 1:
        page = IndexPageFunny();
        break;
      case 2:
        page = IndexPageFocus();
        break;
      default:
        page = Scaffold(
          appBar: AppBar(
            title:Text(_bottomNavList[_currentIndex]),
            backgroundColor: DYBase.defaultColor,
            brightness: Brightness.dark,
            textTheme: TextTheme(
              title: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            )
          ),
          body: Center(child: Text(
              '正在建设中...',
              style: TextStyle(fontSize: 20, color: Colors.black45),
            ),
          ),
        );
        break;
    }
    return page;
  }

  Widget buildBodyView(count) {
    //构造 TabBarView
    return TabBarView(
      //创建Tab页
      children: _navList.asMap().map((i, e) {
        if (i == 0) {
          return MapEntry(i, Container(
            child: Column(
              children: [
                // _header(),
                // _nav(),
                Expanded(
                  flex: 1,
                  child: ListView(
                    padding: EdgeInsets.only(top: 0),
                    children: [
                      _swiper(),
                      _liveTable(count),
                    ],
                  ),
                ),
              ],
            ),
          ));
        }
        return MapEntry(i, Center(child: Text(
            '正在建设中...',
            style: TextStyle(fontSize: 20, color: Colors.black45),
          ),
        ));
      }).values.toList(),
    );
  }

  /*---- 组件化拆分 ----*/
  // Header容器
  Widget _header() {
    return Container(
      width: dp(375),
      height: dp(80),
      padding: EdgeInsets.fromLTRB(dp(10), dp(24), dp(20), 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          // 斗鱼LOGO
          GestureDetector(
            onTap: DYio.clearCache,
            child: Image(
              image: AssetImage('images/dylogo.png'),
              width: dp(76),
              height: dp(34),
            ),
          ),
          // 搜索区域容器
          Expanded(
            flex: 1,
            child: Container(
              width: dp(150),
              height: dp(30),
              margin: EdgeInsets.only(left: dp(15)),
              padding: EdgeInsets.only(left: dp(5), right: dp(5)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(dp(15)),
                ), 
              ),
              child: Row(
                children: <Widget>[
                  // 搜索ICON
                  Image.asset(
                    'images/search.png',
                    width: dp(25),
                    height: dp(15),
                  ),
                  // 搜索输入框
                  Expanded(
                    flex: 1,
                    child: TextField(
                      cursorColor: DYBase.defaultColor,
                      cursorWidth: 1.5,
                      style: TextStyle(
                        color: DYBase.defaultColor,
                        fontSize: 14.0,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(0),
                        hintText: '搜索你想看的直播内容',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 轮播图
  Widget _swiper() {
    return Padding(
      padding: EdgeInsets.all(dp(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(dp(10)),
        ),
        child: Container(
          width: dp(340),
          height: dp(330) / 1.7686,
          child: swiperPic.length < 1 ? null : Swiper(
            controller: swiperController,
            itemBuilder: _swiperBuilder,
            itemCount: swiperPic.length,
            pagination: SwiperPagination(
                builder: DotSwiperPaginationBuilder(
              color: Color.fromRGBO(0, 0, 0, .2),
              activeColor: DYBase.defaultColor,
            )),
            control: SwiperControl(
              size: dp(20),
              color: DYBase.defaultColor,
            ),
            scrollDirection: Axis.horizontal,
            autoplay: true,
            onTap: (index) => print('Swiper pic $index click'),
          ),
        ),
      ),
    );
  }

  Widget _swiperBuilder(BuildContext context, int index) {
    return (Image.network(
      swiperPic[index],
      fit: BoxFit.fill,
    ));
  }

  // 直播列表
  Widget _liveTable(count) {
    return Column(
      children: <Widget>[
        _listTableHeader(count),
        _listTableInfo(),
      ]
    );
  }

  // 直播列表头部
  Widget _listTableHeader(count) {
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
              Text('$count',
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

  // 直播列表详情
  Widget _listTableInfo() {
    final liveList = List<Widget>();
    var fontStyle = TextStyle(
      color: Colors.white,
      fontSize: 12.0
    );

    liveData.forEach((item) {
      liveList.add(
        GestureDetector(
          onTap: () {
            _goToLiveRoom(item);
          },
          child: Padding(
          key: ObjectKey(item['rid']),
          padding: EdgeInsets.all(dp(5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: dp(175),
                  height: dp(101.25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(dp(4)),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(item['roomSrc']),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          width: dp(120),
                          height: dp(18),
                          padding: EdgeInsets.only(right: dp(5)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(topRight: Radius.circular(dp(4))),
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
                          width: dp(175),
                          height: dp(18),
                          padding: EdgeInsets.only(right: dp(5)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(dp(4)),
                              bottomRight: Radius.circular(dp(4)),
                            ),
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
                              Padding(padding: EdgeInsets.only(left: dp(3))),
                              Image.asset(
                                'images/member.png',
                                height: dp(14),
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
                Container(
                  width: dp(175),
                  padding: EdgeInsets.fromLTRB(dp(1), dp(4), 0, 0),
                  child: Text(
                    item['roomName'],
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ],
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

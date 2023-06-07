// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:webview_flutter/webview_flutter.dart';

// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';

// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:window_size/window_size.dart';

// #enddocregion platform_imports

void main() => runApp(const MaterialApp(home: WebViewExample()));

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  static int timerDefault = 30;
  bool _textEnabled = true;
  late final WebViewController _controller;
  final _textEditController = TextEditingController();
  String title = "";
  String htmlbody = "";
  var document;

  @override
  void initState() {
    super.initState();
    _textEditController.text = timerDefault.toString();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            debugPrint('Page finished loading: $url');
            title = await controller.runJavaScriptReturningResult(
                'document.title;'
            ) as String;
            debugPrint(title);
            htmlbody = await controller.runJavaScriptReturningResult(
                'document.getElementsByTagName("body")[0].innerHTML;'
            ) as String;
            htmlbody = (htmlbody).replaceAll(r"\u003c", "<");
            htmlbody = (htmlbody).replaceAll(r"\u003C", "<");
            // body = (body).replaceAll(r"\u003e", ">");
            // body = (body).replaceAll(r"\u003E", ">");
            htmlbody = (htmlbody).replaceAll(r'\"', '"');
            debugPrint(htmlbody);
            debugPrint("3 --------------------------------------");
            List groupItem = parse(htmlbody).getElementsByClassName("list-group-item");
            //List groupItem = parse(body).getElementsByTagName("a");
            // Aタグのhref属性値を取得するには？
            debugPrint(groupItem[2].attributes["href"]);
            String season_url = groupItem[2].attributes["href"];
            List season = season_url.split("season/");
            debugPrint(season[1]);
            // debugPrint(parse(body).getElementsByTagName("a")[0].attributes["href"]);
            debugPrint("4 --------------------------------------");
            // debugPrint(parse(body).getElementsByTagName("a")[0].attributes["href"].toString());
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..setUserAgent(
          "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.62 Safari/537.36")
      ..loadRequest(Uri.parse("https://st-cdn001.akamaized.net/fc10cricvirtuals/en/1/category/1111"));
    //'https://st-cdn001.akamaized.net/fc10cricvirtuals/en/1/category/1111')); //https://flutter.dev'));
    //flutter_windows_3.7.12-stable

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      //designSize: const Size(2000, 2000),
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
            backgroundColor: Colors.green,
            appBar: AppBar(
              title: const Text('Flutter WebView example'),
              // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
              actions: <Widget>[
                NavigationControls(webViewController: _controller),
              ],
            ),
            body: Center(
                child:
                Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                      ),
                      child: SizedBox(
                          child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SizedBox(
                                      width: 800,
                                      height: 1400,
                                      child: Transform.scale(
                                          alignment: Alignment.topLeft,
                                          //scaleX: 0.45,
                                          scale: 0.45,
                                          child: WebViewWidget(
                                              layoutDirection: TextDirection.ltr,
                                              controller: _controller)))))),
                    ),
                  ),
                  Container(
                    child: TextFormField(
                      enabled: _textEnabled,
                      controller: _textEditController,
                    ),
                  ),
                ])),
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                stopButton(),
                const Gap(16),
                startButton(),
              ],
            ));
      },
    );
  }

  Widget startButton() {
    return FloatingActionButton(
      onPressed: _onTimer,
      child: const Icon(Icons.start),
    );
  }

  Widget stopButton() {
    return FloatingActionButton(
      onPressed: _onTimer2,
      child: const Icon(Icons.stop),
    );
  }

  bool _timerRun = false;
  Timer? _timer;
  int _counter = 0;

  void _onTimer2() {

    // String aaa = r"\u003";
    // String bbb = r(aaa).replaceAll(r"\u003", "ABC");
    // debugPrint(bbb);
  }

  void _onTimer() async {
    if (_timerRun) {
      _timer!.cancel();
      _timerRun = false;
      _textEnabled = true;
    } else {
      _timerRun = true;
      _textEnabled = false;
      _counter = int.parse(_textEditController.text);
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
        debugPrint("$_timer?.tick :: $_counter");
        _textEditController.text = _counter.toString();
        if (htmlbody.isNotEmpty) {
          debugPrint("html解析");
          debugPrint(title);
          if (title.startsWith('"Virtual Football - Soccer')) {
            List groupItem = parse(htmlbody).getElementsByClassName("list-group-item");
            String seasonNum = groupItem[2].attributes["href"].split("season/")[1];
            debugPrint("https://st-cdn001.akamaized.net/fc10cricvirtuals/en/1/season/" + seasonNum);
            _controller.loadRequest(Uri.parse("https://st-cdn001.akamaized.net/fc10cricvirtuals/en/1/season/" + seasonNum));
            title = "";
            htmlbody = "";
          //} else if (title.startsWith('"Virtual Football Bundesliga')) {
          } else if (title.startsWith('"Virtual Football League Mode')) {
            // Section取得
            debugPrint("Section取得");
            //debugPrint(htmlbody);
            String panelbody = parse(htmlbody).getElementsByClassName("panel-body")[0].innerHtml;
            //debugPrint(panelbody);
            // String teamData = parse(panelbody).getElementsByTagName("tr")[0].innerHtml;
            // debugPrint(teamData);
            List teamData2 = parse(panelbody).getElementsByTagName("tr");
            //debugPrint(teamData2[1].innerHtml);
            for (int i = 1; i < teamData2.length; i++) {
              List teamData3 = teamData2[i].getElementsByTagName("td");
              final result = teamData3.map((item) => item.text);
              debugPrint(result.join(" "));
              //var result = teamData3.map((item) => item);
              // String aaa = "";
              // teamData3.forEach((item) =>  aaa = aaa + item.text);
              //debugPrint(aaa);
              // teamData3.forEach((item) {
              //   debugPrint(item.text);
              //   // ここでセクション取得
              // });
              // debugPrint(teamData2[i].getElementsByTagName("td")[0].text);
              break;
            }


            //   val team_listdata = panelbody.split("VL ").drop(1)
//   val team_details = team_listdata[1].split(" ")
//   section = team_details[1]

          }

        } else {
          debugPrint("html未取得");
          if (_counter == 0) {
            _counter = 30;
            _controller.reload();
          }
        }

        // if (_counter == 25) {
        //   final String body = await _controller.runJavaScriptReturningResult(
        //       'document.body.innerHTML;'
        //   ) as String;
        //   debugPrint(body);
        // } else if (_counter == 20) {
        //   _controller.reload();
        // } else if (_counter == 10) {
        //   _controller.loadRequest(Uri.parse('https://yahoo.co.jp'));
        // } else if (_counter == 0) {
        //   _counter = 30;
        // }
        _counter--;
      });
    }
    setState(() {});
  }

  String _getSection(String htmlBody, String season) {
    String section = "";

    return section;
  }

//   private fun getSection(htmldoc: Document, season: String): String {
//   Log.d("Test", "========== getSection!! ==========")
//   var section: String = ""
//   var panelbody: String = htmldoc.getElementsByClass("panel-body").text()
//   val team_listdata = panelbody.split("VL ").drop(1)
//   val team_details = team_listdata[1].split(" ")
//   section = team_details[1]
//   return section
//   }
//
//   private fun drawCheck(htmldoc: Document, season: String): String {
//   Log.d("Test", "========== drawCheck!! ==========")
//   var section: String = ""
//   var msg_buf: StringBuilder = StringBuilder()
//
//   // シーズン名取得
//   var headder: String = htmldoc.getElementsByClass("popup-navigation").text()
//   var season_name: String = headder.split(" ").last()
//   Log.d("Test", season_name)
//
//   var panelbody: String = htmldoc.getElementsByClass("panel-body").text()
//   //Log.d("Test", "${htmldoc.toString()} \n $panelbody")
//   val team_listdata = panelbody.split("VL ").drop(1)
//   for(i in 0..31 step 2) {
//   // Log.d("Test", team_listdata[i])     Vienna
//   // Log.d("Test", team_listdata[i+1])   Vienna 8 1 2 5 6 15 -9 5 W L D L D Pos# TeamT P W D L GF GA DIFF PTS Form 1
//   val team_details = team_listdata[i+1].split(" ")
//   // 勝敗履歴
//   var j: Int = 0
//   var wdl: String = ""
//   for(detail in team_details) {
//   if (j >= 9 && j <= 13) {
//   if (detail == "W" || detail == "D" || detail == "L") {
//   wdl += detail
//   } else {
//   break
//   }
//   }
//   j++
//   }
//   var team_name: String = team_details[0]
//   section = team_details[1]
//   // ゲーム履歴を追加
//   if (prev_section != Integer.parseInt(section) && Integer.parseInt(section) > 0) {
//   if (hashmap["$season_name:$team_name"].isNullOrEmpty()) {
//   // 履歴がない場合
//   Log.d("Test", "履歴追加")
//   hashmap["$season_name:$team_name"] = wdl
//   //hashmap["$season:$team_name"] = team_details[9]
//   } else {
//   var tmp = hashmap["$season_name:$team_name"]
//   hashmap["$season_name:$team_name"] = team_details[9] + tmp
//   }
//   }
//
//   var d3: Boolean = wdl.startsWith("DDD")
//   var d4: Boolean = wdl.startsWith("DDDD")
//   var d5: Boolean = wdl.startsWith("DDDDD")
//
//   if (d3 || d4 || d5) {
//   msg_buf.append("$section : ${(i+2)/2} : $team_name:[$wdl]\n")
//   } else {
//   }
//   if (i <= 8) {
//   // 5位まで3戦勝ちなし
//   var w: Int = wdl.indexOf("W")
//   //var l3: Boolean = wdl.startsWith
//   //                // 該当なし("LLL")
//   if ((w < 0) || (w >= 3)) {
//   msg_buf.append("$section : ${(i + 2) / 2} : $team_name:[$wdl]\n")
//   }
//   }
//   if (i == 30) {
//   // 最下位が3連勝
//   if (wdl.startsWith("WWW")) {
//   msg_buf.append("$section: $i: $team_name:[$wdl]\n")
//   }
//   }
// // 信頼度低いので一旦はずす
// //            // 引き分け数が11以上
// //            if (team_details[3].toInt() >= 11) {
// //                var draw = team_details[3]
// //                //msg_buf.append("$section : $i : $team_name:draw $draw:[$wdl]\n")
// //            }
// //            // 11戦以上未勝利
// //            if (section.toInt() >= 11) {
// //                if (team_details[2].toInt() == 0) {
// //                    //msg_buf.append("$section : $i : $team_name:未勝利\n")
// //                }
// //            }
//
//   Log.d("Test", "$section, ${(i+2)/2}, $team_name, $wdl")
//   }
//   if (msg_buf.isNotEmpty()) {
//   sendMessage(msg_buf.toString())
//   Log.d("Test", "msg :: ${msg_buf.toString()}")
//   msg_buf.clear()
//   }
//   prev_section = Integer.parseInt(section)
//   return section
//   }
//
//   // Slackにメッセージ送信
//   fun sendMessage(msg: String) {
//   val webhook: String = "https://hooks.slack.com/services/..."
//   val body: String = "{ \"text\" : \"$msg\" }"
//   Fuel.post(webhook).body(body).response { _, response, result ->
//   Log.d("Send", response.toString())
//   Log.d("Send", result.toString())
//   }
//   Log.d("Test", "sendMessage")
//   }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController});

  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () async {
            if (await webViewController.canGoBack()) {
              await webViewController.goBack();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No back history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () async {
            if (await webViewController.canGoForward()) {
              await webViewController.goForward();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No forward history item')),
                );
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.replay),
          onPressed: () => webViewController.reload(),
        ),
      ],
    );
  }
}
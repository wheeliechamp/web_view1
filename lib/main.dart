// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:window_size/window_size.dart';

// #enddocregion platform_imports

void main() => runApp(
    const MaterialApp(home: WebViewExample())
);

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
  String htmlSrc = "";

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

            //final String body = await controller.runJavaScriptReturningResult(
            htmlSrc = await controller.runJavaScriptReturningResult(
                'document.body.innerHTML;'
            ) as String;
            debugPrint(htmlSrc);
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
      ..setUserAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/93.0.4577.62 Safari/537.36")
      ..loadRequest(Uri.parse('https://st-cdn001.akamaized.net/fc10cricvirtuals/en/1/category/1111'));//https://flutter.dev'));
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
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                    ),

                      child: SizedBox(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,

                          child: SizedBox(
                            width:800,
                           child: Transform.scale(
                               alignment: Alignment.topLeft,
                               //scaleX: 0.45,
                               scale: 0.45,
                                child: WebViewWidget(
                                   //layoutDirection: TextDirection.ltr,
                                   controller: _controller
                               )
                          )
                        )
                    )
                      )


                    //width: 2000,
                    //child: SingleChildScrollView(
                      //scrollDirection: Axis.horizontal,
                      //child: SizedBox(
                        //width: 1000,
                        // child: Transform.scale(
                        //   scale: 0.8,
                        //   child: WebViewWidget(
                        //       layoutDirection: TextDirection.ltr,
                        //       controller: _controller
                        //   )
                        // )               //         )
                      //),
                    //),
                    // child: Transform.scale(
                    //     scale: 0.7,
                    // ),
                      // child: Column(
                        //mainAxisAlignment: MainAxisAlignment.end,
                        //   children: [
                        //     Expanded(
                        //     //child: SizedBox(
                        //       //width: 2000,
                        //       child: Transform.scale(
                        //             scale: 0.5,
                        //             //child: SingleChildScrollView(
                        //               //scrollDirection: Axis.horizontal,
                        //                 //child: SizedBox(
                        //                   //width: 2000,
                        //                     child: WebViewWidget(
                        //                         layoutDirection: TextDirection.ltr,
                        //                         controller: _controller
                        //                     )
                        //                 //),
                        //             //),
                        //         ),
                        //     //),
                        //     ),
                        //     // Container(
                        //     //   child: TextFormField(
                        //     //     enabled: _textEnabled,
                        //     //     controller: _textEditController,
                        //     //   ),
                        //     // ),
                        //   ]
                      // )
                  )
              ),

              // body: WebViewWidget(controller: _controller),
              // body: Center(
              //     child: Container(
              //       children: [
              //         child: Column(
              //           //mainAxisAlignment: MainAxisAlignment.end,
              //               Expanded(
              //                 child: SingleChildScrollView(
              //                   scrollDirection: Axis.horizontal,
              //                   child: SizedBox(
              //                     width: 1500,
              //                     child: WebViewWidget(
              //                         layoutDirection: TextDirection.ltr,
              //                         controller: _controller
              //                     ),
              //                   ),
              //                 // child: Container(
              //                 //     // height: double.infinity,
              //                 //     //width: 1000.w,
              //                 //     //height: 100.h,
              //                 //     child: WebViewWidget(
              //                 //         layoutDirection: TextDirection.ltr,
              //                 //         controller: _controller
              //                 //     )
              //                 // ),
              //                 ),
              //               ),
              //               Container(
              //                 child: TextFormField(
              //                   enabled: _textEnabled,
              //                   controller: _textEditController,
              //                 ),
              //               ),
              //             ]
              //         )
              //     )
              floatingActionButton: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  stopButton(),
                  const Gap(16),
                  startButton(),
                ],
              )
          );
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
      onPressed: _onTimer,
      child: const Icon(Icons.stop),
    );
  }

  bool _timerRun = false;
  Timer? _timer;
  int _counter=0;

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
        _textEditController.text=_counter.toString();
        if (htmlSrc.isNotEmpty) {
          debugPrint("html取得");
          htmlSrc = "";
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

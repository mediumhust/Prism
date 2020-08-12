import 'package:Prism/analytics/analytics_service.dart';
import 'package:Prism/theme/jam_icons_icons.dart';
import 'package:Prism/routes/routing_constants.dart';
// import 'package:Prism/ui/widgets/popup/proPopUp.dart';
import 'package:Prism/ui/widgets/popup/signInPopUp.dart';
import 'package:flutter/material.dart';
import 'package:Prism/theme/toasts.dart' as toasts;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:Prism/main.dart' as main;
import 'package:permission_handler/permission_handler.dart';

class DownloadButton extends StatefulWidget {
  final String link;
  final bool colorChanged;
  const DownloadButton({
    @required this.link,
    @required this.colorChanged,
    Key key,
  }) : super(key: key);

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool isLoading;
  @override
  void initState() {
    isLoading = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        print("Download");
        if (!main.prefs.get("isLoggedin")) {
          googleSignInPopUp(context, () {
            onDownload();
          });
        } else {
          onDownload();
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.25),
                    blurRadius: 4,
                    offset: Offset(0, 4))
              ],
              borderRadius: BorderRadius.circular(500),
            ),
            padding: EdgeInsets.all(17),
            child: Icon(
              JamIcons.download,
              color: Theme.of(context).accentColor,
              size: 30,
            ),
          ),
          Positioned(
              top: 0,
              left: 0,
              height: 63,
              width: 63,
              child: isLoading ? CircularProgressIndicator() : Container())
        ],
      ),
    );
  }

  void showPremiumPopUp(Function func) {
    if (!main.prefs.get("premium")) {
      toasts.codeSend("Variants are a premium feature.");
      Navigator.pushNamed(context, PremiumRoute);
      // premiumPopUp(context, func);
    } else {
      func();
    }
  }

  void onDownload() async {
    if (widget.colorChanged) {
      showPremiumPopUp(() async {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        setState(() {
          isLoading = true;
        });
        print(widget.link);
        toasts.codeSend("Starting Download");
        Future.delayed(Duration(seconds: 2)).then(
          (value) => GallerySaver.saveImage(widget.link, albumName: "Prism")
              .then((value) {
            analytics.logEvent(
                name: 'download_wallpaper', parameters: {'link': widget.link});
            toasts.codeSend("Image Downloaded in Pictures/Prism!");
            setState(() {
              isLoading = false;
            });
          }).catchError(
            (e) {
              // toasts.error(e.toString());
              setState(
                () {
                  isLoading = false;
                },
              );
            },
          ),
        );
      });
    } else {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      setState(() {
        isLoading = true;
      });
      print(widget.link);
      toasts.codeSend("Starting Download");
      GallerySaver.saveImage(widget.link, albumName: "Prism").then((value) {
        analytics.logEvent(
            name: 'download_wallpaper', parameters: {'link': widget.link});
        toasts.codeSend("Image Downloaded in Pictures/Prism!");
        setState(() {
          isLoading = false;
        });
      }).catchError((e) {
        // toasts.error(e.toString());
        setState(() {
          isLoading = false;
        });
      });
    }
  }
}

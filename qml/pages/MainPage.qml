import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components/imgur.js" as Imgur

Page {
    id: mainPage;
    //allowedOrientations: Orientation.All;

    property bool prevEnabled : page > 0;
    property string searchModeText : "";

    Connections {
        target: settings;
        onSettingsLoaded: {
            galleryModel.clear();

            // 0.2-1: oauth disabled
            loggedIn = false;
            Imgur.init(constant.clientId, constant.clientSecret, settings.accessToken, settings.refreshToken, constant.userAgent);
            internal.processGalleryMode();
            // 0.2-1: oauth disabled

            /*
            Imgur.init(constant.clientId, constant.clientSecret, settings.accessToken, settings.refreshToken, constant.userAgent);
            if (settings.accessToken === "" || settings.refreshToken === "") {
                loggedIn = false;
                console.log("Not signed in. Using anonymous mode.");
                infoBanner.showText(qsTr("Not signed in. Using anonymous mode."));
                settings.user = "anonymous";
                internal.processGalleryMode();
            } else {
                loggedIn = true;
                Imgur.getAccountCurrent(function(url) {
                    settings.user = url;
                    internal.processGalleryMode();
                }, function(status, statusText){
                    if (status === 403) {
                        console.log("Permission denied. Trying to refresh tokens.");
                        Imgur.refreshAccessToken(settings.refreshToken, function(access_token, refresh_token){
                            settings.accessToken = access_token;
                            settings.refreshToken = refresh_token;
                            settings.saveTokens();

                            // retry the api call
                            Imgur.getAccountCurrent(function(url) {
                                settings.user = url;
                                internal.processGalleryMode();
                            }, function(status, statusText) {
                                infoBanner.showHttpError(status, statusText);
                                loadingRect.visible = false;
                            });
                        }, function(status, statusText) {
                            loggedIn = false;
                            infoBanner.showHttpError(status, statusText + ". Can't refresh tokens. Please sign in.");
                            loadingRect.visible = false;
                        });
                    } else {
                        infoBanner.showHttpError(status, statusText);
                        loadingRect.visible = false;
                    };
                });
            }*/
        }
    }

    SilicaFlickable {
        id: flickable;

        PageHeader { id: header; title: constant.appName; }

        PullDownMenu {
            id: pullDownMenu;

            MenuItem {
                id: aboutMenu;
                text: qsTr("About");
                onClicked: {
                    aboutPage.load();
                    pageStack.push(aboutPage);
                }
            }

            MenuItem {
                id: settingsMenu;
                text: qsTr("Settings");
                onClicked: {
                    pageStack.push(settingsPage);
                }
            }

            // 0.2-1: oauth disabled
            /*
            MenuItem {
                id: signInMenu;
                text: loggedIn ? qsTr("Logout") : qsTr("Sign In");
                onClicked: {
                    if (loggedIn === false) {
                        pageStack.push(signInPage);
                    } else {
                        settings.resetTokens();
                        settings.settingsLoaded();
                    }
                }
            }
            */
            // 0.2-1: oauth disabled

            SearchField {
                id: searchTextField;

                width: parent.width;
                font.pixelSize: constant.fontSizeSmall;
                font.bold: false;
                placeholderText: qsTr("Search...");

                EnterKey.enabled: text.trim().length > 0;
                EnterKey.iconSource: "image://theme/icon-m-enter-accept";
                EnterKey.onClicked: {
                    //console.log("Searched: " + query);
                    searchModeText = "Results for \"" + text + "\"";
                    galleryModel.clear();
                    internal.processGalleryMode();
                    pullDownMenu.close();
                    searchTextField.focus = false;
                }
            }

        } // Pulldown menu

        PushUpMenu {
            id: pushUpMenu;

            MenuItem {
                ListItem {
                    id: navigation;

                    Label {
                        id: prev;
                        text: qsTr("« Previous");
                        font.pixelSize: constant.fontSizeSmall;

                        anchors.left: parent.left;
                        anchors.leftMargin: constant.paddingMedium;

                        MouseArea {
                            anchors.fill: parent;
                            onClicked: {
                                if (page > 0) {
                                    page -= 1;
                                }
                                //console.log("Previous clicked!: " + page);
                                internal.processGalleryMode();
                                if (page == 0) {
                                    prevEnabled = false;
                                }
                                pushUpMenu.close();
                                galgrid.scrollToTop();
                            }
                        }
                        enabled: prevEnabled;
                        visible: prevEnabled;
                    }

                    Label {
                        id: next;
                        text: qsTr("Next »");
                        font.pixelSize: constant.fontSizeSmall;

                        anchors.right: parent.right;
                        anchors.rightMargin: constant.paddingMedium;

                        MouseArea {
                            anchors.fill: parent;
                            onClicked: {
                                page += 1;
                                //console.log("Next clicked!: " + page);
                                internal.processGalleryMode();
                                prevEnabled = true;
                                pushUpMenu.close();
                                galgrid.scrollToTop();
                            }
                        }
                    }
                } // ListItem
            }
        } // Pushup menu

        anchors.fill: parent;

        GalleryMode { id: galleryMode; }

        SilicaGridView {
            id: galgrid;

            cellWidth: 175;
            cellHeight: 175;
            clip: true;

            model: galleryModel;

            anchors { top: galleryMode.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; }
            anchors.leftMargin: constant.paddingSmall;
            anchors.rightMargin: constant.paddingSmall;

            delegate: GalleryDelegate { id: galleryDelegate; }

            VerticalScrollDecorator { flickable: galgrid; }
        } // SilicaGridView

        FancyGridScroller {
            flickable: galgrid;
        }
    }

    Component.onCompleted: {
        galleryModel.clear();
    }

    QtObject {
        id: internal;

        function processGalleryMode() {
            loadingRect.visible = true;
            galleryModel.clear();

            Imgur.processGalleryMode(settings.mode, searchTextField.text,
                function(status){
                    loadingRect.visible = false;
                    if(currentIndex == -1) {
                        currentIndex = galleryModel.count - 1;
                    }
                }, function(status, statusText){
                    infoBanner.showHttpError(status, statusText);
                    loadingRect.visible = false;
                }
            );
        }
    }
}

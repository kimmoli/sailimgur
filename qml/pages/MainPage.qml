import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components/imgur.js" as Imgur

Page {
    id: root;
    allowedOrientations: Orientation.All;

    signal modeChanged(string mode);

    Connections {
        target: settings;
        onSettingsLoaded: {
            if (settings.installedVersion === "" || settings.installedVersion !== APP_VERSION) {
                settings.installedVersion = APP_VERSION;
                settings.saveSetting("installedVersion", settings.installedVersion);
                pageStack.push(Qt.resolvedUrl("ChangelogDialog.qml"));
            }

            galleryModel.showNsfw = settings.showNsfw;
            galleryModel.clear();
            signInPage.refreshDone = false;
            loadingRect.visible = false;

            signInPage.init();
            if (settings.accessToken === "" || settings.refreshToken === "") {
                loggedIn = false;
                console.log("Not signed in. Using anonymous mode.");
                infoBanner.showText(qsTr("Not signed in. Using anonymous mode."));
                settings.user = qsTr("anonymous");
                galleryModel.processGalleryMode();
            } else {
                Imgur.getAccountCurrent(
                    internal.accountCurrentOnSuccess(),
                    internal.accountCurrentOnFailure()
                );
            }
        }

        onSettingsSaved: {
            galleryModel.showNsfw = settings.showNsfw;
        }
    }

    Connections {
        target: settingsDialog;
        onToolbarPositionChanged: {
            galgrid.state = "reanchored";
        }
    }

    QtObject {
        id: internal;

        function accountCurrentOnSuccess() {
            return function(url) {
                loggedIn = true;
                settings.user = url;
                galleryModel.processGalleryMode();
            }
        }

        function accountCurrentOnFailure() {
            return function(status, statusText) {
                if (status === 403 && signInPage.refreshDone == false) {
                    signInPage.refreshDone = true;
                    signInPage.tryRefreshingTokens(
                        function() {
                            Imgur.getAccountCurrent(
                               internal.accountCurrentOnSuccess(),
                               internal.accountCurrentOnFailure()
                           );
                        }
                    );
                } else {
                    infoBanner.showHttpError(status, statusText);
                    loadingRect.visible = false;
                };
            }
        }
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: {
            // Main page grid scroll
            if (event.key === Qt.Key_Down) {
                galgrid.flick(0, -750);
                event.accepted = true;
            }
            if (event.key === Qt.Key_Up) {
                galgrid.flick(0, 750);
                event.accepted = true;
            }

            // Changing gallery
            if (event.key === Qt.Key_1) {
                modeChanged("main");
                event.accepted = true;
            }
            if (event.key === Qt.Key_2) {
                modeChanged("user");
                event.accepted = true;
            }
            if (event.key === Qt.Key_3) {
                modeChanged("random");
                event.accepted = true;
            }
            if (event.key === Qt.Key_4) {
                modeChanged("top");
                event.accepted = true;
            }
            if (event.key === Qt.Key_5) {
                modeChanged("memes");
                event.accepted = true;
            }
        }
    }

    SilicaFlickable {
        id: flickable;
        pressDelay: 0;
        z: -2;

        anchors.fill: parent;
        contentHeight: parent.height; contentWidth: parent.width;

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
                    pageStack.push(settingsDialog);
                }
            }
        }

        SilicaGridView {
            id: galgrid;

            cellWidth: {
                if (Screen.sizeCategory >= Screen.Large)
                    return Math.floor((deviceOrientation === Orientation.Landscape || deviceOrientation === Orientation.LandscapeInverted) ? width / 7 : width / 5);
                else 
                    return Math.floor((deviceOrientation === Orientation.Landscape || deviceOrientation === Orientation.LandscapeInverted) ? width / 5 : width / 3);
                }
            cellHeight: cellWidth;
            clip: true;
            pressDelay: 0;

            model: galleryModel;

            anchors { left: parent.left; right: parent.right; }
            //anchors.top: (settings.toolbarBottom) ? parent.top : (actionBar.visible ? actionBar.bottom : parent.top);
            //anchors.bottom: (settings.toolbarBottom) ? (actionBar.visible ? actionBar.top : parent.bottom) : parent.bottom;

            delegate: Loader {
                sourceComponent: GalleryDelegate { id: galleryDelegate; }
            }

            VerticalScrollDecorator { flickable: galgrid; }

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right; margins: Theme.paddingLarge; }
                color: Theme.highlightBackgroundColor;
                visible: (galleryModel.busy) ? 1 : 0;

                Label {
                    id: statusLabel;
                    anchors { left: parent.left; right: parent.right; centerIn: parent; }
                    text: "Loading...";
                    color: constant.colorHighlight;
                }
            }

            // Load next/previous page when at the end or at the top
            onMovementEnded: {
                if (atYBeginning) {
                    actionBar.shown = true;
                }

                if(atYEnd) {
                    page += 1;
                    //console.log("atYEnd: " + page);
                    statusLabel.text = qsTr("Loading next page");
                    galleryModel.nextPage(galleryModel.query, true);
                }
            }

            transitions: Transition {
                // smoothly reanchor galgrid and move into new position
                AnchorAnimation { duration: 1000; easing.type: Easing.Linear; }
            }

            states:
                State {
                    name: "reanchored"

                    AnchorChanges {
                        target: actionBar;
                        anchors.top: (settings.toolbarBottom) ? undefined : parent.top;
                        anchors.bottom: (settings.toolbarBottom) ? parent.bottom : undefined;
                    }

                    AnchorChanges {
                        target: galgrid;
                        anchors.top: (settings.toolbarBottom) ? parent.top : (actionBar.visible ? actionBar.bottom : parent.top);
                        anchors.bottom: (settings.toolbarBottom) ? (actionBar.visible ? actionBar.top : parent.bottom) : parent.bottom;
                    }
                }
        } // SilicaGridView

        ActionBar {
            id: actionBar;
            flickable: galgrid;
        }
    }

    Component.onCompleted: {
        galgrid.state = "reanchored";
        galleryModel.clear();
    }

}

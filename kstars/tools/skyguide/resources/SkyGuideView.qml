/***************************************************************************
                          SkyGuideView.qml  -  K Desktop Planetarium
                             -------------------
    begin                : 2015/07/01
    copyright            : (C) 2015 by Marcos Cardinot
    email                : mcardinot@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

ColumnLayout {
    id: view
    spacing: 0
    property int fontSizeText: 12
    property int frameBorderWidth: 1
    property int frameHMargin: 10
    property int frameVMargin: 10

    property var historyPrev: []
    property var historyNext: []
    property var currentPage: null
    property int maxHistLenght: 16

    function loadPage(page) {
        if (!page.hasOwnProperty('name') || !page.hasOwnProperty('modelData')) {
            console.log("SkyGuideQML:loadPage(PAGE): PAGE should hold a name and a modelData!");
            return false;
        } else if (currentPage && currentPage.name === page.name && currentPage.modelData === page.modelData) {
            return false;
        }

        var src;
        if (page.name === "HOME") {
            src = "SkyGuideHome.qml";
        } else if (page.name === "INFO") {
            src = "SkyGuideInfo.qml";
        } else if (page.name === "SLIDE") {
            src = "SkyGuideSlide.qml";
        } else {
            console.log("SkyGuideQML: " + page.name + " is not a valid page!");
            return false;
        }

        if (page.modelData) {
            loader.modelData = page.modelData;
        }

        loader.source = src;
        currentPage = page;
        return true;
    }

    function updateHistorySettings() {
        if (historyNext.length + historyPrev.length > maxHistLenght) {
            historyPrev.splice(0, 1); // remove the oldest one
        }
        btnPrev.enabled = historyPrev.length > 0;
        btnNext.enabled = historyNext.length > 0;
    }

    function goPrev() {
        var cPage = currentPage;
        var prevPageIdx = historyPrev.length - 1;
        if (prevPageIdx > -1 && loadPage(historyPrev[prevPageIdx])) {
            historyNext.push(cPage);
            historyPrev.splice(prevPageIdx, 1);
            updateHistorySettings();
        }
    }

    function goNext() {
        var cPage = currentPage;
        var nextPageIdx = historyNext.length - 1;
        if (nextPageIdx > -1 && loadPage(historyNext[nextPageIdx])) {
            historyNext.splice(nextPageIdx, 1);
            historyPrev.push(cPage);
            updateHistorySettings();
        }
    }

    function goToPage(newPage) {
        var cPage = currentPage;
        if (loadPage(newPage)) {
            historyNext = [];
            if (cPage) historyPrev.push(cPage);
            updateHistorySettings();
        }
    }

    ToolBar {
        Layout.alignment: Qt.AlignTop
        Layout.preferredWidth: 360
        Layout.fillWidth: true
        RowLayout {
            anchors.fill: parent
            ToolButton {
                id: btnPrev
                width: 20
                height: 20
                iconSource: "icons/prev.png"
                onClicked: goPrev()
            }
            ToolButton {
                id: btnNext
                width: 20
                height: 20
                iconSource: "icons/next.png"
                onClicked: goNext()
            }
            ToolButton {
                width: 20
                height: 20
                iconSource: "icons/home.png"
                onClicked: goToPage({'name': 'HOME', 'modelData': null})
            }
            Item { Layout.fillWidth: true }
        }
    }

    Loader {
        id: loader
        Layout.alignment: Qt.AlignCenter
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.minimumHeight: 360
        focus: true
        property var modelData: null
        Component.onCompleted: goToPage({'name': 'HOME', 'modelData': null})
    }

    Item {
        Layout.minimumHeight: 5
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    ToolBar {
        id: menu
        Layout.alignment: Qt.AlignBottom
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        property int btnHeight: 40
        property int btnWidth: 35

        RowLayout {
            id: menuHome
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            ToolButton {
                width: menu.btnWidth
                height: menu.btnHeight
                iconSource: "icons/add.png"
                tooltip: "Add a SkyGuide"
            }
            ToolButton {
                width: menu.btnWidth
                height: menu.btnHeight
                iconSource: "icons/write.png"
                tooltip: "Make a SkyGuide"
            }
            Item { Layout.fillWidth: true }
        }

        RowLayout {
            id: menuSlide
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            ToolButton {
                width: menu.btnWidth
                height: menu.btnHeight
                iconSource: "icons/info.png"
                tooltip: "Contents"
            }
            ToolButton {
                width: menu.btnWidth
                height: menu.btnHeight
                iconSource: "icons/prevSlide.png"
                tooltip: "Previous Slide"
            }
            ToolButton {
                width: menu.btnWidth
                height: menu.btnHeight
                iconSource: "icons/nextSlide.png"
                tooltip: "Next Slide"
            }
            Item { Layout.fillWidth: true }
        }
    }
}
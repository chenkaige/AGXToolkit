//
//  AGXWebViewJavascriptBridgeJS.m
//  AGXWebView
//
//  Created by Char Aznable on 16/3/4.
//  Copyright © 2016年 AI-CUC-EC. All rights reserved.
//

//
//  Copyright (c) 2011-2015 Marcus Westin, Antoine Lagadec
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "AGXWebViewJavascriptBridgeJS.h"

#define __agx_wvjb_js_func__(x) #x

NSString *AGXWebViewJavascriptBridgeSetupJS() {
    static NSString *setupJS = @__agx_wvjb_js_func__
    (
     if (!window.AGXBridge) {
         var AGXBIframe = document.createElement('iframe');
         AGXBIframe.style.display = 'none';
         AGXBIframe.src = 'agxscheme://__BRIDGE_LOADED__';
         document.documentElement.appendChild(AGXBIframe);
         setTimeout(function() { document.documentElement.removeChild(AGXBIframe) }, 0);
     }
     ); // __agx_wvjb_js_func__
    
    return setupJS;
}

NSString *AGXWebViewJavascriptBridgeJS() {
    static NSString * preprocessorJSCode = @__agx_wvjb_js_func__
    (;(function() {
        if (window.AGXBridge) return;
        
        window.AGXBridge = {
            registerHandler: registerHandler,
            callHandler: callHandler,
            _fetchQueue: _fetchQueue,
            _handleMessageFromObjC: _handleMessageFromObjC
        };
        
        var messagingIframe;
        var sendMessageQueue = [];
        var messageHandlers = {};
        
        var CUSTOM_PROTOCOL_SCHEME = 'agxscheme';
        var QUEUE_HAS_MESSAGE = '__AGX_QUEUE_MESSAGE__';
        
        var responseCallbacks = {};
        var uniqueId = 1;
        
        function registerHandler(handlerName, handler) {
            messageHandlers[handlerName] = handler;
        }
        
        function callHandler(handlerName, data, responseCallback) {
            if (arguments.length == 2 && typeof data == 'function') {
                responseCallback = data;
                data = null;
            }
            _doSend({ handlerName:handlerName, data:data }, responseCallback);
        }
        
        function _doSend(message, responseCallback) {
            if (responseCallback) {
                var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
                responseCallbacks[callbackId] = responseCallback;
                message['callbackId'] = callbackId;
            }
            sendMessageQueue.push(message);
            messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
        }
        
        function _fetchQueue() {
            var messageQueueString = JSON.stringify(sendMessageQueue);
            sendMessageQueue = [];
            return messageQueueString;
        }
        
        function _dispatchMessageFromObjC(messageJSON) {
            setTimeout(function _timeoutDispatchMessageFromObjC() {
                var message = JSON.parse(messageJSON);
                var messageHandler;
                var responseCallback;
                
                if (message.responseId) {
                    responseCallback = responseCallbacks[message.responseId];
                    if (!responseCallback) {
                        return;
                    }
                    responseCallback(message.responseData);
                    delete responseCallbacks[message.responseId];
                } else {
                    if (message.callbackId) {
                        var callbackResponseId = message.callbackId;
                        responseCallback = function(responseData) {
                            _doSend({ responseId:callbackResponseId, responseData:responseData });
                        };
                    }
                    
                    var handler = messageHandlers[message.handlerName];
                    try {
                        handler(message.data, responseCallback);
                    } catch(exception) {
                        console.log("AGXBridge: WARNING: javascript handler threw.", message, exception);
                    }
                    if (!handler) {
                        console.log("AGXBridge: WARNING: no handler for message from ObjC:", message);
                    }
                }
            });
        }
        
        function _handleMessageFromObjC(messageJSON) {
            _dispatchMessageFromObjC(messageJSON);
        }
        
        messagingIframe = document.createElement('iframe');
        messagingIframe.style.display = 'none';
        messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
        document.documentElement.appendChild(messagingIframe);
     })(); // function
    ); // __agx_wvjb_js_func__
    
    return preprocessorJSCode;
}

#undef __agx_wvjb_js_func__
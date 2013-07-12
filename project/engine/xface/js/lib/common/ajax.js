
/*
 This file was modified from or inspired by Apache Cordova.

 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements. See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership. The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied. See the License for the
 specific language governing permissions and limitations
 under the License.
*/

var privateModule = require('xFace/privateModule');
XMLHttpRequest.prototype.open_raw  = XMLHttpRequest.prototype.open;
XMLHttpRequest.prototype.open = function(m, u, b) {
  if(privateModule.isSecurityMode())
  {
    if(url.indexOf("http")==-1)
    {
     this.open_raw(m, u, b);
    }else
    {
        //TODO:目前异步请求不稳定，待处理
        this.open_raw(m, url, false);
    }
  }else
  {
     this.open_raw(m, u, b);
  }
  if(xFace.iOSAppAddr)
  {
     //用于在引擎内部区分不同xapp的请求（iOS only）
     this.setRequestHeader('app', xFace.iOSAppAddr);
  }
};

function redirectUrl(url)
{
   var TOKEN ="_xface_proxy_ajax_";
   var reurl = url;

   //TODO:https 的支持
   if(url.indexOf("http") != -1 && privateModule.isSecurityMode())
   {
    //需要进行重定向
      reurl = "/"+ TOKEN +"/" + url;
   }
   return reurl;
}

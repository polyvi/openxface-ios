/**
  * 该模块实现了ajax对象,通过该对象可以实现跨域访问
  * @module XMLHttpRequest
  * @main XMLHttpRequest
  */
 var argscheck = require('xFace/argscheck'),
     exec = require('xFace/exec'),
     utils = require('xFace/utils');

/**
  * 该类定义了AJAX请求对象相关接口（Android, iOS）<br/>
  * 该类通过new来创建相应的对象<br/>
  * @class XMLHttpRequest
  * @example
        var xhr = new xFace.XMLHttpRequest(); //构造ajax对象
  * @namespace xFace
  * @constructor
  * @platform Android, iOS
  * @since 3.0.0
  */
var XMLHttpRequest = function()
{
   /**
     *  每次 readyState 属性改变的时候调用的事件句柄函数（Android，iOS）<br/>
     * @property onreadystatechange
     * @type Function
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.onreadystatechange = null;

   /**
     * HTTP请求发生网络错误时调用的句柄函数（Android，iOS）<br/>
     * @property onerror
     * @type Function
     * @platform Android, iOS
     * @since 3.0.0
     */
    this.onerror = null; 

   /**
     * HTTP请求被中断时调用的句柄函数,比如调用abort方法 该句柄函数会被触发（Android，iOS）<br/>
     * @property onabort
     * @type Function
     * @platform Android, iOS
     * @since 3.0.0
     */
   this.onabort = null;

    /**
      * HTTP 请求的状态.当一个 XMLHttpRequest 初次创建时，这个属性的值从 0 开始，直到接收到完整的 HTTP 响应，这个值增加到 4（Android，iOS）<br/>
        状态                           名称                                        描述<br/>
         0       UNSEND               初始化状态, XMLHttpRequest 对象已创建或已被 abort() 方法重置；<br/>
         1       OPENED               open()方法已调用；<br/>
         2       HEADERS_RECEIVED     所有响应头部都已经接收到 <br/>
         3       LOADING              正在接收服务器响应体数据 <br/>
         4       DONE                 数据接收完毕或者请求被中断 <br/>
      * @property readyState
      * @type Number
      * @platform Android, iOS
      * @since 3.0.0
      */
    this.readyState = 0;

    /**
      * 从服务器接收到的响应体（不包括头部），或者如果还没有接收到数据的话，就是空字符串（Android，iOS）<br/>
      * @property responseText
      * @type String
      * @platform Android, iOS
      * @since 3.0.0
      */
    this.responseText = null;

    /**
      * 由服务器返回的 HTTP 状态代码，如 200 表示成功，而 404 表示 "Not Found" 错误（Android，iOS）<br/>
      * @property status
      * @type  Number
      * @platform Android, iOS
      * @since 3.0.0
      */
    this.status = 0;
    this.id = utils.createUUID(); // 这里通过uuid标示每个ajax对象
    this.headers = null;
    var me = this;
    this.success =function(result){
        if(typeof me.onreadystatechange === "function" ){
            me.readyState = result.readyState;
            me.status = result.status;
            me.responseText = result.responseText;
            me.headers = result.headers;
            me.onreadystatechange();
        }
    }
    this.failure = function(result){
        me.readyState = result.readyState;
        me.status = result.status;
        me.responseText = result.responseText;
        me.headers = result.headers;

        var type = result.eventType;
        if( type == 1 && typeof me.onerror == "function"){
            me.onerror();
        }else if(type == 0 && typeof me.onabort == "function"){
            me.onabort();
        }
    }
};

/**
  *  返回指定的 HTTP 响应头部的值。其参数是要返回的 HTTP 响应头部的名称（Android, iOS）<br/>
  *  @example
        var client = new xFace.XMLHttpRequest();
        client.open("GET", "http://www.polyvi.net:8012/develop/Ajax/ajax_get.php");
        client.send();
        client.onreadystatechange = function() {
         if(this.readyState == 2) {
           print(client.getResponseHeader("Content-Type"));
         }
}
  *  @method getResponseHeader
  * @param {String} name 需要返回的HTTP响应头部的名称
  *  @platform Android, iOS
  *  @since 3.0.0
  */
XMLHttpRequest.prototype.getResponseHeader = function(name)
{
  argscheck.checkArgs('s', 'XMLHttpRequest.getResponseHeader', arguments);
  return this.headers[name];
};


/**
  *  把 HTTP 响应头部作为未解析的字符串返回,如果 readyState 小于 3，这个方法返回 null。否则，它返回服务器发送的所有 HTTP 响应的头部。
     头部作为单个的字符串返回，一行一个头部。每行用换行符 "\r\n" 隔开（Android, iOS）<br/>
  *  @example
        var client = new xFace.XMLHttpRequest();
        client.open("GET", "http://www.polyvi.net:8012/develop/Ajax/ajax_get.php");
        client.send();
        client.onreadystatechange = function() {
        if(this.readyState == 2) {
           print(this.getAllResponseHeaders());
         }
}
  *  @method getAllResponseHeaders
  *  @platform Android, iOS
  *  @since 3.0.0
  */
XMLHttpRequest.prototype.getAllResponseHeaders = function()
{
    var str = "";
    for(var p in this.headers)
    {
        if(typeof(this.headers[p]) == "string")
        {
            str =str + p + ": " +  this.headers[p] + "\r\n"
        }
    }
    return str;
};

/**
  *  初始化 HTTP 请求参数，例如 URL 和 HTTP 方法(注意目前仅仅支持 GET 和 POST 方法 )但不发送请求，仅仅支持异步（Android, iOS）<br/>
  *  @example
        var client = new xFace.XMLHttpRequest();
        client.open("GET", "http://www.polyvi.net:8012/develop/Ajax/ajax_get.php");
        client.send();
        client.onreadystatechange = function() {
         if(this.readyState == 4) {
      print(this.getAllResponseHeaders());
        }
}
  *  @method open
  *  @param {String} method 用于请求HTTP的方法 值包括POST, GET
  *  @param {String} url 请求的host地址(仅仅支持http和https)
  *  @platform Android, iOS
  *  @since 3.0.0
  */
XMLHttpRequest.prototype.open = function(method, url){
    argscheck.checkArgs('ss', 'XMLHttpRequest.open', arguments);
    exec(this.success, this.failure, null, 'XMLHttpRequest', 'open', [this.id, method, url]);
};
/**
  *  发送 HTTP 请求，使用传递给 open() 方法的参数，以及传递给该方法的可选请求体（Android, iOS）<br/>
  *  @example
        var client = new xFace.XMLHttpRequest();
        client.open("GET", "http://www.polyvi.net:8012/develop/Ajax/ajax_get.php");
        client.send();
        client.onreadystatechange = function() {
        if(this.readyState == 4) {
        print(this.getAllResponseHeaders());
        }
}
  *  @method send
  *  @param {String} [data] 向服务器post的数据
  *  @platform Android, iOS
  *  @since 3.0.0
  */
XMLHttpRequest.prototype.send = function(data){
    argscheck.checkArgs('S', 'XMLHttpRequest', 'send', arguments);
    exec(null, null, null,'XMLHttpRequest', 'send', [this.id, data]);
};

/**
  *  取消当前响应，关闭连接并且结束任何未决的网络活动，这个方法把 XMLHttpRequest 对象重置为 readyState 为 0 的状态，并且取消所有未决的网络活动。例如，如果请求用了太长时间，而且响应不再必要的时候，可以调用这个方法（Android, iOS）<br/>
  *  @example
        var client = new xFace.XMLHttpRequest();
        client.open("GET", "http://www.polyvi.net:8012/develop/Ajax/ajax_get.php");
        client.send();
        client.abort();
        client.onabort = function(){alert('abort');}
}
  *  @method abort
  *  @platform Android, iOS
  *  @since 3.0.0
  */
XMLHttpRequest.prototype.abort = function(){
    exec(null, null, null, 'XMLHttpRequest', 'abort', [this.id]);
};

/**
  *  向一个打开但未发送的请求设置或添加一个 HTTP 请求头部（Android, iOS）<br/>
  *  @example
      var client = new xFace.XMLHttpRequest();
      client.open("GET", "http://www.polyvi.net:8012/develop/Ajax/ajax_get.php");
      client.setRequestHeader("agent","xface");
      client.send();
  *  @method setRequestHeader
  *  @param {String} name 头部的名称
  *  @param {String} value 头部的值
  *  @platform Android, iOS
  *  @since 3.0.0
  */
XMLHttpRequest.prototype.setRequestHeader= function(name, value){
    exec(null, null, null, 'XMLHttpRequest', 'setRequestHeader' , [this.id, name, value]);
};

module.exports = XMLHttpRequest;

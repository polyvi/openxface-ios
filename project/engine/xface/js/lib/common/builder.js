
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

var utils = require('xFace/utils');

function each(objects, func, context) {
    for (var prop in objects) {
        if (objects.hasOwnProperty(prop)) {
            func.apply(context, [objects[prop], prop]);
        }
    }
}

function include(parent, objects, clobber, merge) {
    each(objects, function (obj, key) {
        try {
          var type = 'String';
          var len = 1;
          if(obj.path) {
            type = Object.prototype.toString.call(obj.path).slice(8, -1);
            if(type === 'Array') {
                len = obj.path.length;
            }
          }
          var result = null;
          for(var i = 0; i < len; i++) {
            result = (type === 'Array' ? require(obj.path[i]) : (obj.path ? require(obj.path) : {}));
            if (clobber) {
              // Clobber if it doesn't exist.
              if (typeof parent[key] === 'undefined') {
                  parent[key] = result;
              } else if (typeof obj.path !== 'undefined') {
                  // If merging, merge properties onto parent, otherwise, clobber.
                  if (merge) {
                      recursiveMerge(parent[key], result);
                  } else {
                      parent[key] = result;
                  }
              }
              result = parent[key];
            } else {
                // Overwrite if not currently defined.
                if (typeof parent[key] == 'undefined') {
                  parent[key] = result;
                } else if (merge && typeof obj.path !== 'undefined') {
                  // If merging, merge parent onto result
                  recursiveMerge(result, parent[key]);
                  parent[key] = result;
                } else {
                  // Set result to what already exists, so we can build children into it if they exist.
                  result = parent[key];
                }
            }
          }

          if (obj.children) {
            include(result, obj.children, clobber, merge);
          }
        } catch(e) {
          utils.alert('Exception building xFace JS globals: ' + e + ' for key "' + key + '"');
        }
    });
}

/**
 * 递归的合并一个对象的属性到另一个对象上，如果源对象和目标对象的属性相同，则源对象的属性值会覆盖目标对象
 *
 * @param target 目标对象
 * @param src    源对象
 */
function recursiveMerge(target, src) {
    for (var prop in src) {
        if (src.hasOwnProperty(prop)) {
            if (typeof target.prototype !== 'undefined' && target.prototype.constructor === target) {
                // If the target object is a constructor override off prototype.
                target.prototype[prop] = src[prop];
            } else {
                target[prop] = typeof src[prop] === 'object' ? recursiveMerge(
                        target[prop], src[prop]) : src[prop];
            }
        }
    }
    return target;
}

module.exports = {
    build: function (objects) {
        return {
            intoButDontClobber: function (target) {
                include(target, objects, false, false);
            },
            intoAndClobber: function(target) {
                include(target, objects, true, false);
            },
            intoAndMerge: function(target) {
                include(target, objects, true, true);
            }
        };
    }
};
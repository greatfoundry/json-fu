(function() {
  var FunctionSigil, JSONNavigator, JSONPath, JSONSigil, JSONSpace, MoreSigil, NullSigil, RefSigil, UndefinedSigil, fromJsonSpace, toJsonSpace;
  var __slice = Array.prototype.slice, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  String.prototype.smartSplit = function(separator) {
    var char, curIdx, inDoubleQuote, inQuote, inSingleQuote, parts, splitIdx, _i, _len;
    inSingleQuote = false;
    inDoubleQuote = false;
    inQuote = function() {
      return inSingleQuote || inDoubleQuote;
    };
    parts = [];
    splitIdx = 0;
    curIdx = 0;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      char = this[_i];
      if (char === '"' && !inSingleQuote) {
        inDoubleQuote = !inDoubleQuote;
      }
      if (char === '\'' && !inDoubleQuote) {
        inSingleQuote = !inSingleQuote;
      }
      if (char === separator && !inQuote()) {
        parts.push(this.substr(splitIdx, curIdx - splitIdx));
        splitIdx = curIdx;
        splitIdx++;
      }
      curIdx++;
    }
    if (splitIdx < curIdx) {
      parts.push(this.substr(splitIdx, curIdx - splitIdx));
    }
    return parts;
  };
  JSONPath = (function() {
    JSONPath.className = "JSONPath";
    JSONPath.fromString = function(string) {
      var arg, args, path, _i, _len;
      path = new JSONPath;
      if (!(string != null)) {
        return path;
      }
      string = string.replace("(", "");
      string = string.replace(")", "");
      args = string.smartSplit(',');
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        arg = args[_i];
        path.pathComponents.push(arg);
      }
      return path;
    };
    function JSONPath() {
      var pathComponent, pathComponents, _i, _len;
      pathComponents = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      this.pathComponents = [];
      for (_i = 0, _len = pathComponents.length; _i < _len; _i++) {
        pathComponent = pathComponents[_i];
        this.pathComponents.push(pathComponent);
      }
    }
    JSONPath.prototype.length = function() {
      return this.pathComponents.length;
    };
    JSONPath.prototype.leadingComponent = function() {
      return this.pathComponents[0];
    };
    JSONPath.prototype.lastComponent = function() {
      return this.pathComponents[this.pathComponents.length - 1];
    };
    JSONPath.prototype.pathByRemovingComponent = function() {
      var first;
      first = this.pathComponents.slice(0, this.pathComponents.length - 1);
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(JSONPath, first, function() {});
    };
    JSONPath.prototype.pathByAppendingComponent = function(component) {
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(JSONPath, __slice.call(this.pathComponents).concat([component]), function() {});
    };
    JSONPath.prototype.pathWithoutLeadingComponent = function() {
      var rest;
      rest = this.pathComponents.slice(1);
      return (function(func, args, ctor) {
        ctor.prototype = func.prototype;
        var child = new ctor, result = func.apply(child, args);
        return typeof result === "object" ? result : child;
      })(JSONPath, rest, function() {});
    };
    JSONPath.prototype.toString = function() {
      var component;
      return "(" + ((function() {
        var _i, _len, _ref, _results;
        _ref = this.pathComponents;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          component = _ref[_i];
          _results.push(component);
        }
        return _results;
      }).call(this)) + ")";
    };
    JSONPath.prototype.toJSON = function() {
      return toString();
    };
    return JSONPath;
  })();
  JSONNavigator = (function() {
    JSONNavigator.className = "JSONNavigator";
    function JSONNavigator(root) {
      this.root = root != null ? root : null;
    }
    JSONNavigator.prototype.objectAtPath = function(path) {
      var child, childNav, restOfPath, thisComponent;
      thisComponent = path.leadingComponent();
      restOfPath = path.pathWithoutLeadingComponent();
      if (!(thisComponent != null) && restOfPath.length > 0) {
        return;
      }
      if (!(thisComponent != null)) {
        return this.root;
      }
      child = this.root[thisComponent];
      if (!(child != null)) {
        return;
      }
      childNav = new JSONNavigator(child);
      return childNav.objectAtPath(restOfPath);
    };
    return JSONNavigator;
  })();
  JSONSpace = (function() {
    JSONSpace.className = "JSONSpace";
    function JSONSpace(parent, prev, next) {
      this.parent = parent != null ? parent : null;
      this.prev = prev != null ? prev : null;
      this.next = next != null ? next : null;
      this.children = null;
      this.value = void 0;
    }
    JSONSpace.prototype.addChild = function(child, key) {
      var brother;
      if (key == null) {
        key = null;
      }
      if (!(this.children != null) && !(key != null)) {
        this.children = [];
      } else if (!this.children && (key != null)) {
        this.children = {};
      }
      child.parent = this;
      child.next = null;
      child.prev = null;
      if (this.children.length > 0) {
        brother = this.children[this.children.length - 1];
        child.prev = brother;
        brother.next = child;
      }
      if (key != null) {
        return this.children[key] = child;
      } else {
        return this.children.push(child);
      }
    };
    JSONSpace.prototype.toJSON = function() {
      var child, hash, key, value, _i, _len, _ref, _ref2, _results;
      if (!this.children) {
        if (this.value.toJSON != null) {
          return this.value.toJSON();
        } else {
          return this.value;
        }
      } else if (this.children instanceof Array) {
        _ref = this.children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          _results.push(child);
        }
        return _results;
      } else if (typeof this.children === 'object') {
        hash = {};
        _ref2 = this.children;
        for (key in _ref2) {
          value = _ref2[key];
          hash[key] = value;
        }
        return hash;
      }
    };
    return JSONSpace;
  })();
  JSONSigil = (function() {
    JSONSigil.className = "JSONSigil";
    JSONSigil.prefix = "__@JSON_";
    JSONSigil.factory = {};
    JSONSigil.sigilFromName = function(name) {
      var argPos, args, cls, sigil;
      args = "";
      argPos = name.indexOf("(");
      if (argPos !== -1) {
        args = name.substr(argPos + 1, name.length - argPos - 2);
      }
      if (argPos !== -1) {
        name = name.substr(0, argPos);
      }
      cls = this.factory[name];
      if (cls != null) {
        sigil = new cls();
        if (args !== "") {
          sigil.parseArgs(args.smartSplit(','));
        }
        return sigil;
      } else {
        return null;
      }
    };
    function JSONSigil(name) {
      this.name = name != null ? name : "";
      JSONSigil.factory[this.name] = this.constructor;
    }
    JSONSigil.prototype.parseArgs = function(args) {};
    JSONSigil.prototype.value = function() {};
    JSONSigil.prototype.toString = function() {
      return "" + JSONSigil.prefix + this.name;
    };
    JSONSigil.prototype.toJSON = function() {
      return this.toString();
    };
    return JSONSigil;
  })();
  NullSigil = (function() {
    __extends(NullSigil, JSONSigil);
    NullSigil.className = "NullSigil";
    function NullSigil() {
      NullSigil.__super__.constructor.call(this, "null");
    }
    NullSigil.prototype.value = function() {
      return null;
    };
    return NullSigil;
  })();
  UndefinedSigil = (function() {
    __extends(UndefinedSigil, JSONSigil);
    UndefinedSigil.className = "UndefinedSigil";
    function UndefinedSigil() {
      UndefinedSigil.__super__.constructor.call(this, "undefined");
    }
    UndefinedSigil.prototype.value = function() {
      return;
    };
    return UndefinedSigil;
  })();
  MoreSigil = (function() {
    __extends(MoreSigil, JSONSigil);
    MoreSigil.className = "MoreSigil";
    function MoreSigil(count) {
      this.count = count != null ? count : null;
      MoreSigil.__super__.constructor.call(this, "more");
    }
    MoreSigil.prototype.parseArgs = function(args) {
      if (!(args != null) || (args != null ? args.length : void 0) === 0) {
        return this.count = 0;
      } else {
        return this.count = parseInt(args[0]);
      }
    };
    MoreSigil.prototype.toString = function() {
      if (this.count != null) {
        return "" + MoreSigil.__super__.toString.apply(this, arguments) + "(" + this.count + ")";
      } else {
        return MoreSigil.__super__.toString.apply(this, arguments);
      }
    };
    return MoreSigil;
  })();
  RefSigil = (function() {
    __extends(RefSigil, JSONSigil);
    RefSigil.className = "RefSigil";
    RefSigil.isRefSigil = function(name) {
      return name.lastIndexOf("" + JSONSigil.prefix + "ref", 0) === 0;
    };
    function RefSigil(path) {
      this.path = path != null ? path : new JSONPath;
      RefSigil.__super__.constructor.call(this, "ref");
    }
    RefSigil.prototype.parseArgs = function(args) {
      var components, pathComponent;
      if (!(args != null) || (args != null ? args.length : void 0) === 0) {
        return this.path = new JSONPath;
      } else {
        components = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = args.length; _i < _len; _i++) {
            pathComponent = args[_i];
            _results.push(pathComponent);
          }
          return _results;
        })();
        return this.path = (function(func, args, ctor) {
          ctor.prototype = func.prototype;
          var child = new ctor, result = func.apply(child, args);
          return typeof result === "object" ? result : child;
        })(JSONPath, components, function() {});
      }
    };
    RefSigil.prototype.value = function(root) {
      var nav;
      if (!(root != null)) {
        return;
      }
      nav = new JSONNavigator(root);
      return nav.objectAtPath(this.path);
    };
    RefSigil.prototype.toString = function() {
      return "" + RefSigil.__super__.toString.apply(this, arguments) + (this.path.toString());
    };
    return RefSigil;
  })();
  FunctionSigil = (function() {
    __extends(FunctionSigil, JSONSigil);
    FunctionSigil.className = "FunctionSigil";
    function FunctionSigil() {
      FunctionSigil.__super__.constructor.call(this, "function");
    }
    FunctionSigil.prototype.value = function() {
      return function() {};
    };
    return FunctionSigil;
  })();
  toJsonSpace = function(object, parentSpace, path, depthLimit, sigils) {
    var child, count, i, key, objectPath, space, subspace, testObject, value, _i, _j, _k, _len, _len2, _len3;
    space = new JSONSpace(parentSpace);
    if (object instanceof JSONSpace) {
      throw "object is already a JSONSpace";
    } else if ((depthLimit != null) && path.length() > depthLimit) {
      if (!sigils) {
        return null;
      }
      space.value = new MoreSigil;
    } else if (object === void 0) {
      if (!sigils) {
        return null;
      }
      space.value = new UndefinedSigil;
    } else if (object === null) {
      if (!sigils) {
        return null;
      }
      space.value = new NullSigil;
    } else if (typeof object === 'function') {
      if (!sigils) {
        return null;
      }
      space.value = new FunctionSigil;
    }
    if (typeof objectCache === "undefined" || objectCache === null) {
      objectCache = [];
    }
    objectPath = null;
    for (_i = 0, _len = objectCache.length; _i < _len; _i++) {
      testObject = objectCache[_i];
      if (sigils) {
        if (testObject.ref === object) {
          objectPath = testObject.path;
          break;
        }
      }
    }
    if ((objectPath != null) && sigils) {
      space.value = new RefSigil(objectPath);
    }
    if (space.value != null) {
      if (sigils) {
        return space;
      }
      return null;
    }
    switch (typeof object) {
      case 'string':
        space.value = "" + object;
        break;
      case 'number':
        space.value = object;
        break;
      case 'boolean':
        space.value = object;
        break;
      case 'object':
        space.value = object;
        if (object instanceof Array) {
          if ((depthLimit != null) && path.length() + 1 > depthLimit) {
            if (!sigils) {
              return null;
            }
            count = 0;
            for (_j = 0, _len2 = object.length; _j < _len2; _j++) {
              value = object[_j];
              count++;
            }
            space.value = new MoreSigil(count);
          } else {
            objectCache.push({
              ref: object,
              path: path
            });
            space.children = [];
            i = 0;
            for (_k = 0, _len3 = object.length; _k < _len3; _k++) {
              child = object[_k];
              subspace = toJsonSpace(child, space, path.pathByAppendingComponent(i), depthLimit, sigils);
              if (subspace != null) {
                space.addChild(subspace);
              }
              i++;
            }
          }
        } else {
          if ((depthLimit != null) && path.length() + 1 > depthLimit) {
            if (!sigils) {
              return null;
            }
            count = 0;
            for (value in object) {
              count++;
            }
            space.value = new MoreSigil(count);
          } else {
            if (sigils) {
              objectCache.push({
                ref: object,
                path: path
              });
            }
            space.children = {};
            for (key in object) {
              value = object[key];
              subspace = toJsonSpace(value, space, path.pathByAppendingComponent(key), depthLimit, sigils);
              if (subspace != null) {
                space.addChild(subspace, key);
              }
            }
          }
        }
        break;
      default:
        throw "Don't know how to turn object of type " + (typeof object) + " into a JSONSpace";
    }
    return space;
  };
  fromJsonSpace = function(space, references, path) {
    var arr, child, i, key, obj, ret, sigil, value, _len, _ref, _ref2;
    if (references == null) {
      references = {};
    }
    if (path == null) {
      path = new JSONPath;
    }
    ret = void 0;
    if ((space.children != null) && space.children instanceof Array) {
      arr = [];
      _ref = space.children;
      for (i = 0, _len = _ref.length; i < _len; i++) {
        child = _ref[i];
        arr.push(fromJsonSpace(child, references, path.pathByAppendingComponent(i)));
      }
      ret = arr;
    } else if (space.children != null) {
      obj = {};
      _ref2 = space.children;
      for (key in _ref2) {
        value = _ref2[key];
        obj[key] = fromJsonSpace(value, references, path.pathByAppendingComponent(key));
      }
      ret = obj;
    } else {
      if (typeof space.value === 'string' && space.value.lastIndexOf(JSONSigil.prefix, 0) === 0) {
        sigil = JSONSigil.sigilFromName(space.value.substr(JSONSigil.prefix.length));
        if (!(sigil != null)) {
          ret = space.value;
        } else if (RefSigil.isRefSigil(space.value)) {
          references[path] = sigil;
          ret = void 0;
        } else {
          ret = sigil.value();
        }
      } else {
        ret = space.value;
      }
    }
    return ret;
  };
  exports.VERSION = '0.1.0';
  exports.selectObject = function(root, jpath) {
    var component, components, jsonPath;
    if (!(jpath != null) || jpath.trim() === "") {
      return;
    }
    if (!(root != null)) {
      return;
    }
    components = jpath.split('/');
    jsonPath = (function(func, args, ctor) {
      ctor.prototype = func.prototype;
      var child = new ctor, result = func.apply(child, args);
      return typeof result === "object" ? result : child;
    })(JSONPath, (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = components.length; _i < _len; _i++) {
        component = components[_i];
        if (component !== '') {
          _results.push(component);
        }
      }
      return _results;
    })(), function() {});
    return new JSONNavigator(root).objectAtPath(jsonPath);
  };
  exports.stringify = function(object, depth, replacer) {
    if (depth == null) {
      depth = null;
    }
    if (replacer == null) {
      replacer = null;
    }
    if (!(depth != null)) {
      return JSON.stringify(object, replacer);
    } else {
      return JSON.stringify(toJsonSpace(object, null, new JSONPath, depth, false), replacer);
    }
  };
  exports.serialize = function(object, depth, replacer) {
    if (depth == null) {
      depth = null;
    }
    if (replacer == null) {
      replacer = null;
    }
    return JSON.stringify(toJsonSpace(object, null, new JSONPath, depth, true), replacer);
  };
  exports.parse = function(json, reviver) {
    if (reviver == null) {
      reviver = null;
    }
    return JSON.parse(json, reviver);
  };
  exports.deserialize = function(json, reviver) {
    var graph, jsonSpace, nav, obj, parent, path, pathString, references, sigil;
    if (reviver == null) {
      reviver = null;
    }
    graph = JSON.parse(json, reviver);
    jsonSpace = toJsonSpace(graph, null, new JSONPath);
    references = {};
    obj = fromJsonSpace(jsonSpace, references);
    nav = new JSONNavigator(obj);
    for (pathString in references) {
      sigil = references[pathString];
      path = JSONPath.fromString(pathString);
      parent = nav.objectAtPath(path.pathByRemovingComponent());
      parent[path.lastComponent()] = sigil.value(obj);
    }
    return obj;
  };
}).call(this);

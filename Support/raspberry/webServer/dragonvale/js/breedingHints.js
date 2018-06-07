;(function(window, document, angular) {

/*!
 * modernizr v3.3.1
 * Build http://modernizr.com/download?-es5array-es6array-es6string-addtest-fnbind-printshiv-testprop-dontmin
 *
 * Copyright (c)
 *  Faruk Ates
 *  Paul Irish
 *  Alex Sexton
 *  Ryan Seddon
 *  Patrick Kettner
 *  Stu Cox
 *  Richard Herrera

 * MIT License
 */

/*
 * Modernizr tests which native CSS3 and HTML5 features are available in the
 * current UA and makes the results available to you in two ways: as properties on
 * a global `Modernizr` object, and as classes on the `<html>` element. This
 * information allows you to progressively enhance your pages with a granular level
 * of control over the experience.
*/

var tests = [];
  

  /**
   *
   * ModernizrProto is the constructor for Modernizr
   *
   * @class
   * @access public
   */

  var ModernizrProto = {
    // The current version, dummy
    _version: '3.3.1',

    // Any settings that don't work as separate modules
    // can go in here as configuration.
    _config: {
      'classPrefix': '',
      'enableClasses': true,
      'enableJSClass': true,
      'usePrefixes': true
    },

    // Queue of tests
    _q: [],

    // Stub these for people who are listening
    on: function(test, cb) {
      // I don't really think people should do this, but we can
      // safe guard it a bit.
      // -- NOTE:: this gets WAY overridden in src/addTest for actual async tests.
      // This is in case people listen to synchronous tests. I would leave it out,
      // but the code to *disallow* sync tests in the real version of this
      // function is actually larger than this.
      var self = this;
      setTimeout(function() {
        cb(self[test]);
      }, 0);
    },

    addTest: function(name, fn, options) {
      tests.push({name: name, fn: fn, options: options});
    },

    addAsyncTest: function(fn) {
      tests.push({name: null, fn: fn});
    }
  };

  

  // Fake some of Object.create so we can force non test results to be non "own" properties.
  var Modernizr = function() {};
  Modernizr.prototype = ModernizrProto;

  // Leak modernizr globally when you `require` it rather than force it here.
  // Overwrite name so constructor name is nicer :D
  Modernizr = new Modernizr();

  

  var classes = [];
  

  /**
   * is returns a boolean if the typeof an obj is exactly type.
   *
   * @access private
   * @function is
   * @param {*} obj - A thing we want to check the type of
   * @param {string} type - A string to compare the typeof against
   * @returns {boolean}
   */

  function is(obj, type) {
    return typeof obj === type;
  }
  ;

  /**
   * Run through all tests and detect their support in the current UA.
   *
   * @access private
   */

  function testRunner() {
    var featureNames;
    var feature;
    var aliasIdx;
    var result;
    var nameIdx;
    var featureName;
    var featureNameSplit;

    for (var featureIdx in tests) {
      if (tests.hasOwnProperty(featureIdx)) {
        featureNames = [];
        feature = tests[featureIdx];
        // run the test, throw the return value into the Modernizr,
        // then based on that boolean, define an appropriate className
        // and push it into an array of classes we'll join later.
        //
        // If there is no name, it's an 'async' test that is run,
        // but not directly added to the object. That should
        // be done with a post-run addTest call.
        if (feature.name) {
          featureNames.push(feature.name.toLowerCase());

          if (feature.options && feature.options.aliases && feature.options.aliases.length) {
            // Add all the aliases into the names list
            for (aliasIdx = 0; aliasIdx < feature.options.aliases.length; aliasIdx++) {
              featureNames.push(feature.options.aliases[aliasIdx].toLowerCase());
            }
          }
        }

        // Run the test, or use the raw value if it's not a function
        result = is(feature.fn, 'function') ? feature.fn() : feature.fn;


        // Set each of the names on the Modernizr object
        for (nameIdx = 0; nameIdx < featureNames.length; nameIdx++) {
          featureName = featureNames[nameIdx];
          // Support dot properties as sub tests. We don't do checking to make sure
          // that the implied parent tests have been added. You must call them in
          // order (either in the test, or make the parent test a dependency).
          //
          // Cap it to TWO to make the logic simple and because who needs that kind of subtesting
          // hashtag famous last words
          featureNameSplit = featureName.split('.');

          if (featureNameSplit.length === 1) {
            Modernizr[featureNameSplit[0]] = result;
          } else {
            // cast to a Boolean, if not one already
            /* jshint -W053 */
            if (Modernizr[featureNameSplit[0]] && !(Modernizr[featureNameSplit[0]] instanceof Boolean)) {
              Modernizr[featureNameSplit[0]] = new Boolean(Modernizr[featureNameSplit[0]]);
            }

            Modernizr[featureNameSplit[0]][featureNameSplit[1]] = result;
          }

          classes.push((result ? '' : 'no-') + featureNameSplit.join('-'));
        }
      }
    }
  }
  ;

  /**
   * hasOwnProp is a shim for hasOwnProperty that is needed for Safari 2.0 support
   *
   * @author kangax
   * @access private
   * @function hasOwnProp
   * @param {object} object - The object to check for a property
   * @param {string} property - The property to check for
   * @returns {boolean}
   */

  // hasOwnProperty shim by kangax needed for Safari 2.0 support
  var hasOwnProp;

  (function() {
    var _hasOwnProperty = ({}).hasOwnProperty;
    /* istanbul ignore else */
    /* we have no way of testing IE 5.5 or safari 2,
     * so just assume the else gets hit */
    if (!is(_hasOwnProperty, 'undefined') && !is(_hasOwnProperty.call, 'undefined')) {
      hasOwnProp = function(object, property) {
        return _hasOwnProperty.call(object, property);
      };
    }
    else {
      hasOwnProp = function(object, property) { /* yes, this can give false positives/negatives, but most of the time we don't care about those */
        return ((property in object) && is(object.constructor.prototype[property], 'undefined'));
      };
    }
  })();

  

  /**
   * docElement is a convenience wrapper to grab the root element of the document
   *
   * @access private
   * @returns {HTMLElement|SVGElement} The root element of the document
   */

  var docElement = document.documentElement;
  

  /**
   * A convenience helper to check if the document we are running in is an SVG document
   *
   * @access private
   * @returns {boolean}
   */

  var isSVG = docElement.nodeName.toLowerCase() === 'svg';
  

  /**
   * setClasses takes an array of class names and adds them to the root element
   *
   * @access private
   * @function setClasses
   * @param {string[]} classes - Array of class names
   */

  // Pass in an and array of class names, e.g.:
  //  ['no-webp', 'borderradius', ...]
  function setClasses(classes) {
    var className = docElement.className;
    var classPrefix = Modernizr._config.classPrefix || '';

    if (isSVG) {
      className = className.baseVal;
    }

    // Change `no-js` to `js` (independently of the `enableClasses` option)
    // Handle classPrefix on this too
    if (Modernizr._config.enableJSClass) {
      var reJS = new RegExp('(^|\\s)' + classPrefix + 'no-js(\\s|$)');
      className = className.replace(reJS, '$1' + classPrefix + 'js$2');
    }

    if (Modernizr._config.enableClasses) {
      // Add the new classes
      className += ' ' + classPrefix + classes.join(' ' + classPrefix);
      isSVG ? docElement.className.baseVal = className : docElement.className = className;
    }

  }

  ;


   // _l tracks listeners for async tests, as well as tests that execute after the initial run
  ModernizrProto._l = {};

  /**
   * Modernizr.on is a way to listen for the completion of async tests. Being
   * asynchronous, they may not finish before your scripts run. As a result you
   * will get a possibly false negative `undefined` value.
   *
   * @memberof Modernizr
   * @name Modernizr.on
   * @access public
   * @function on
   * @param {string} feature - String name of the feature detect
   * @param {function} cb - Callback function returning a Boolean - true if feature is supported, false if not
   * @example
   *
   * ```js
   * Modernizr.on('flash', function( result ) {
   *   if (result) {
   *    // the browser has flash
   *   } else {
   *     // the browser does not have flash
   *   }
   * });
   * ```
   */

  ModernizrProto.on = function(feature, cb) {
    // Create the list of listeners if it doesn't exist
    if (!this._l[feature]) {
      this._l[feature] = [];
    }

    // Push this test on to the listener list
    this._l[feature].push(cb);

    // If it's already been resolved, trigger it on next tick
    if (Modernizr.hasOwnProperty(feature)) {
      // Next Tick
      setTimeout(function() {
        Modernizr._trigger(feature, Modernizr[feature]);
      }, 0);
    }
  };

  /**
   * _trigger is the private function used to signal test completion and run any
   * callbacks registered through [Modernizr.on](#modernizr-on)
   *
   * @memberof Modernizr
   * @name Modernizr._trigger
   * @access private
   * @function _trigger
   * @param {string} feature - string name of the feature detect
   * @param {function|boolean} [res] - A feature detection function, or the boolean =
   * result of a feature detection function
   */

  ModernizrProto._trigger = function(feature, res) {
    if (!this._l[feature]) {
      return;
    }

    var cbs = this._l[feature];

    // Force async
    setTimeout(function() {
      var i, cb;
      for (i = 0; i < cbs.length; i++) {
        cb = cbs[i];
        cb(res);
      }
    }, 0);

    // Don't trigger these again
    delete this._l[feature];
  };

  /**
   * addTest allows you to define your own feature detects that are not currently
   * included in Modernizr (under the covers it's the exact same code Modernizr
   * uses for its own [feature detections](https://github.com/Modernizr/Modernizr/tree/master/feature-detects)). Just like the offical detects, the result
   * will be added onto the Modernizr object, as well as an appropriate className set on
   * the html element when configured to do so
   *
   * @memberof Modernizr
   * @name Modernizr.addTest
   * @optionName Modernizr.addTest()
   * @optionProp addTest
   * @access public
   * @function addTest
   * @param {string|object} feature - The string name of the feature detect, or an
   * object of feature detect names and test
   * @param {function|boolean} test - Function returning true if feature is supported,
   * false if not. Otherwise a boolean representing the results of a feature detection
   * @example
   *
   * The most common way of creating your own feature detects is by calling
   * `Modernizr.addTest` with a string (preferably just lowercase, without any
   * punctuation), and a function you want executed that will return a boolean result
   *
   * ```js
   * Modernizr.addTest('itsTuesday', function() {
   *  var d = new Date();
   *  return d.getDay() === 2;
   * });
   * ```
   *
   * When the above is run, it will set Modernizr.itstuesday to `true` when it is tuesday,
   * and to `false` every other day of the week. One thing to notice is that the names of
   * feature detect functions are always lowercased when added to the Modernizr object. That
   * means that `Modernizr.itsTuesday` will not exist, but `Modernizr.itstuesday` will.
   *
   *
   *  Since we only look at the returned value from any feature detection function,
   *  you do not need to actually use a function. For simple detections, just passing
   *  in a statement that will return a boolean value works just fine.
   *
   * ```js
   * Modernizr.addTest('hasJquery', 'jQuery' in window);
   * ```
   *
   * Just like before, when the above runs `Modernizr.hasjquery` will be true if
   * jQuery has been included on the page. Not using a function saves a small amount
   * of overhead for the browser, as well as making your code much more readable.
   *
   * Finally, you also have the ability to pass in an object of feature names and
   * their tests. This is handy if you want to add multiple detections in one go.
   * The keys should always be a string, and the value can be either a boolean or
   * function that returns a boolean.
   *
   * ```js
   * var detects = {
   *  'hasjquery': 'jQuery' in window,
   *  'itstuesday': function() {
   *    var d = new Date();
   *    return d.getDay() === 2;
   *  }
   * }
   *
   * Modernizr.addTest(detects);
   * ```
   *
   * There is really no difference between the first methods and this one, it is
   * just a convenience to let you write more readable code.
   */

  function addTest(feature, test) {

    if (typeof feature == 'object') {
      for (var key in feature) {
        if (hasOwnProp(feature, key)) {
          addTest(key, feature[ key ]);
        }
      }
    } else {

      feature = feature.toLowerCase();
      var featureNameSplit = feature.split('.');
      var last = Modernizr[featureNameSplit[0]];

      // Again, we don't check for parent test existence. Get that right, though.
      if (featureNameSplit.length == 2) {
        last = last[featureNameSplit[1]];
      }

      if (typeof last != 'undefined') {
        // we're going to quit if you're trying to overwrite an existing test
        // if we were to allow it, we'd do this:
        //   var re = new RegExp("\\b(no-)?" + feature + "\\b");
        //   docElement.className = docElement.className.replace( re, '' );
        // but, no rly, stuff 'em.
        return Modernizr;
      }

      test = typeof test == 'function' ? test() : test;

      // Set the value (this is the magic, right here).
      if (featureNameSplit.length == 1) {
        Modernizr[featureNameSplit[0]] = test;
      } else {
        // cast to a Boolean, if not one already
        /* jshint -W053 */
        if (Modernizr[featureNameSplit[0]] && !(Modernizr[featureNameSplit[0]] instanceof Boolean)) {
          Modernizr[featureNameSplit[0]] = new Boolean(Modernizr[featureNameSplit[0]]);
        }

        Modernizr[featureNameSplit[0]][featureNameSplit[1]] = test;
      }

      // Set a single class (either `feature` or `no-feature`)
      /* jshint -W041 */
      setClasses([(!!test && test != false ? '' : 'no-') + featureNameSplit.join('-')]);
      /* jshint +W041 */

      // Trigger the event
      Modernizr._trigger(feature, test);
    }

    return Modernizr; // allow chaining.
  }

  // After all the tests are run, add self to the Modernizr prototype
  Modernizr._q.push(function() {
    ModernizrProto.addTest = addTest;
  });

  


/**
  * @optionName html5printshiv
  * @optionProp html5printshiv
  */

  // Take the html5 variable out of the html5shiv scope so we can return it.
  var html5;
  if (!isSVG) {

    /**
     * @preserve HTML5 Shiv 3.7.3 | @afarkas @jdalton @jon_neal @rem | MIT/GPL2 Licensed
     */
    ;(function(window, document) {
      /*jshint evil:true */
      /** version */
      var version = '3.7.3';

      /** Preset options */
      var options = window.html5 || {};

      /** Used to skip problem elements */
      var reSkip = /^<|^(?:button|map|select|textarea|object|iframe|option|optgroup)$/i;

      /** Not all elements can be cloned in IE **/
      var saveClones = /^(?:a|b|code|div|fieldset|h1|h2|h3|h4|h5|h6|i|label|li|ol|p|q|span|strong|style|table|tbody|td|th|tr|ul)$/i;

      /** Detect whether the browser supports default html5 styles */
      var supportsHtml5Styles;

      /** Name of the expando, to work with multiple documents or to re-shiv one document */
      var expando = '_html5shiv';

      /** The id for the the documents expando */
      var expanID = 0;

      /** Cached data for each document */
      var expandoData = {};

      /** Detect whether the browser supports unknown elements */
      var supportsUnknownElements;

      (function() {
        try {
          var a = document.createElement('a');
          a.innerHTML = '<xyz></xyz>';
          //if the hidden property is implemented we can assume, that the browser supports basic HTML5 Styles
          supportsHtml5Styles = ('hidden' in a);

          supportsUnknownElements = a.childNodes.length == 1 || (function() {
            // assign a false positive if unable to shiv
            (document.createElement)('a');
            var frag = document.createDocumentFragment();
            return (
              typeof frag.cloneNode == 'undefined' ||
                typeof frag.createDocumentFragment == 'undefined' ||
                typeof frag.createElement == 'undefined'
            );
          }());
        } catch(e) {
          // assign a false positive if detection fails => unable to shiv
          supportsHtml5Styles = true;
          supportsUnknownElements = true;
        }

      }());

      /*--------------------------------------------------------------------------*/

      /**
       * Creates a style sheet with the given CSS text and adds it to the document.
       * @private
       * @param {Document} ownerDocument The document.
       * @param {String} cssText The CSS text.
       * @returns {StyleSheet} The style element.
       */
      function addStyleSheet(ownerDocument, cssText) {
        var p = ownerDocument.createElement('p'),
          parent = ownerDocument.getElementsByTagName('head')[0] || ownerDocument.documentElement;

        p.innerHTML = 'x<style>' + cssText + '</style>';
        return parent.insertBefore(p.lastChild, parent.firstChild);
      }

      /**
       * Returns the value of `html5.elements` as an array.
       * @private
       * @returns {Array} An array of shived element node names.
       */
      function getElements() {
        var elements = html5.elements;
        return typeof elements == 'string' ? elements.split(' ') : elements;
      }

      /**
       * Extends the built-in list of html5 elements
       * @memberOf html5
       * @param {String|Array} newElements whitespace separated list or array of new element names to shiv
       * @param {Document} ownerDocument The context document.
       */
      function addElements(newElements, ownerDocument) {
        var elements = html5.elements;
        if(typeof elements != 'string'){
          elements = elements.join(' ');
        }
        if(typeof newElements != 'string'){
          newElements = newElements.join(' ');
        }
        html5.elements = elements +' '+ newElements;
        shivDocument(ownerDocument);
      }

      /**
       * Returns the data associated to the given document
       * @private
       * @param {Document} ownerDocument The document.
       * @returns {Object} An object of data.
       */
      function getExpandoData(ownerDocument) {
        var data = expandoData[ownerDocument[expando]];
        if (!data) {
          data = {};
          expanID++;
          ownerDocument[expando] = expanID;
          expandoData[expanID] = data;
        }
        return data;
      }

      /**
       * returns a shived element for the given nodeName and document
       * @memberOf html5
       * @param {String} nodeName name of the element
       * @param {Document} ownerDocument The context document.
       * @returns {Object} The shived element.
       */
      function createElement(nodeName, ownerDocument, data){
        if (!ownerDocument) {
          ownerDocument = document;
        }
        if(supportsUnknownElements){
          return ownerDocument.createElement(nodeName);
        }
        if (!data) {
          data = getExpandoData(ownerDocument);
        }
        var node;

        if (data.cache[nodeName]) {
          node = data.cache[nodeName].cloneNode();
        } else if (saveClones.test(nodeName)) {
          node = (data.cache[nodeName] = data.createElem(nodeName)).cloneNode();
        } else {
          node = data.createElem(nodeName);
        }

        // Avoid adding some elements to fragments in IE < 9 because
        // * Attributes like `name` or `type` cannot be set/changed once an element
        //   is inserted into a document/fragment
        // * Link elements with `src` attributes that are inaccessible, as with
        //   a 403 response, will cause the tab/window to crash
        // * Script elements appended to fragments will execute when their `src`
        //   or `text` property is set
        return node.canHaveChildren && !reSkip.test(nodeName) && !node.tagUrn ? data.frag.appendChild(node) : node;
      }

      /**
       * returns a shived DocumentFragment for the given document
       * @memberOf html5
       * @param {Document} ownerDocument The context document.
       * @returns {Object} The shived DocumentFragment.
       */
      function createDocumentFragment(ownerDocument, data){
        if (!ownerDocument) {
          ownerDocument = document;
        }
        if(supportsUnknownElements){
          return ownerDocument.createDocumentFragment();
        }
        data = data || getExpandoData(ownerDocument);
        var clone = data.frag.cloneNode(),
          i = 0,
          elems = getElements(),
          l = elems.length;
        for(;i<l;i++){
          clone.createElement(elems[i]);
        }
        return clone;
      }

      /**
       * Shivs the `createElement` and `createDocumentFragment` methods of the document.
       * @private
       * @param {Document|DocumentFragment} ownerDocument The document.
       * @param {Object} data of the document.
       */
      function shivMethods(ownerDocument, data) {
        if (!data.cache) {
          data.cache = {};
          data.createElem = ownerDocument.createElement;
          data.createFrag = ownerDocument.createDocumentFragment;
          data.frag = data.createFrag();
        }


        ownerDocument.createElement = function(nodeName) {
          //abort shiv
          if (!html5.shivMethods) {
            return data.createElem(nodeName);
          }
          return createElement(nodeName, ownerDocument, data);
        };

        ownerDocument.createDocumentFragment = Function('h,f', 'return function(){' +
                                                        'var n=f.cloneNode(),c=n.createElement;' +
                                                        'h.shivMethods&&(' +
                                                        // unroll the `createElement` calls
                                                        getElements().join().replace(/[\w\-:]+/g, function(nodeName) {
          data.createElem(nodeName);
          data.frag.createElement(nodeName);
          return 'c("' + nodeName + '")';
        }) +
          ');return n}'
                                                       )(html5, data.frag);
      }

      /*--------------------------------------------------------------------------*/

      /**
       * Shivs the given document.
       * @memberOf html5
       * @param {Document} ownerDocument The document to shiv.
       * @returns {Document} The shived document.
       */
      function shivDocument(ownerDocument) {
        if (!ownerDocument) {
          ownerDocument = document;
        }
        var data = getExpandoData(ownerDocument);

        if (html5.shivCSS && !supportsHtml5Styles && !data.hasCSS) {
          data.hasCSS = !!addStyleSheet(ownerDocument,
                                        // corrects block display not defined in IE6/7/8/9
                                        'article,aside,dialog,figcaption,figure,footer,header,hgroup,main,nav,section{display:block}' +
                                        // adds styling not present in IE6/7/8/9
                                        'mark{background:#FF0;color:#000}' +
                                        // hides non-rendered elements
                                        'template{display:none}'
                                       );
        }
        if (!supportsUnknownElements) {
          shivMethods(ownerDocument, data);
        }
        return ownerDocument;
      }

      /*--------------------------------------------------------------------------*/

      /**
       * The `html5` object is exposed so that more elements can be shived and
       * existing shiving can be detected on iframes.
       * @type Object
       * @example
       *
       * // options can be changed before the script is included
       * html5 = { 'elements': 'mark section', 'shivCSS': false, 'shivMethods': false };
       */
      var html5 = {

        /**
         * An array or space separated string of node names of the elements to shiv.
         * @memberOf html5
         * @type Array|String
         */
        'elements': options.elements || 'abbr article aside audio bdi canvas data datalist details dialog figcaption figure footer header hgroup main mark meter nav output picture progress section summary template time video',

        /**
         * current version of html5shiv
         */
        'version': version,

        /**
         * A flag to indicate that the HTML5 style sheet should be inserted.
         * @memberOf html5
         * @type Boolean
         */
        'shivCSS': (options.shivCSS !== false),

        /**
         * Is equal to true if a browser supports creating unknown/HTML5 elements
         * @memberOf html5
         * @type boolean
         */
        'supportsUnknownElements': supportsUnknownElements,

        /**
         * A flag to indicate that the document's `createElement` and `createDocumentFragment`
         * methods should be overwritten.
         * @memberOf html5
         * @type Boolean
         */
        'shivMethods': (options.shivMethods !== false),

        /**
         * A string to describe the type of `html5` object ("default" or "default print").
         * @memberOf html5
         * @type String
         */
        'type': 'default',

        // shivs the document according to the specified `html5` object options
        'shivDocument': shivDocument,

        //creates a shived element
        createElement: createElement,

        //creates a shived documentFragment
        createDocumentFragment: createDocumentFragment,

        //extends list of elements
        addElements: addElements
      };

      /*--------------------------------------------------------------------------*/

      // expose html5
      window.html5 = html5;

      // shiv the document
      shivDocument(document);

      /*------------------------------- Print Shiv -------------------------------*/

      /** Used to filter media types */
      var reMedia = /^$|\b(?:all|print)\b/;

      /** Used to namespace printable elements */
      var shivNamespace = 'html5shiv';

      /** Detect whether the browser supports shivable style sheets */
      var supportsShivableSheets = !supportsUnknownElements && (function() {
        // assign a false negative if unable to shiv
        var docEl = document.documentElement;
        return !(
          typeof document.namespaces == 'undefined' ||
            typeof document.parentWindow == 'undefined' ||
            typeof docEl.applyElement == 'undefined' ||
            typeof docEl.removeNode == 'undefined' ||
            typeof window.attachEvent == 'undefined'
        );
      }());

      /*--------------------------------------------------------------------------*/

      /**
       * Wraps all HTML5 elements in the given document with printable elements.
       * (eg. the "header" element is wrapped with the "html5shiv:header" element)
       * @private
       * @param {Document} ownerDocument The document.
       * @returns {Array} An array wrappers added.
       */
      function addWrappers(ownerDocument) {
        var node,
        nodes = ownerDocument.getElementsByTagName('*'),
          index = nodes.length,
          reElements = RegExp('^(?:' + getElements().join('|') + ')$', 'i'),
          result = [];

        while (index--) {
          node = nodes[index];
          if (reElements.test(node.nodeName)) {
            result.push(node.applyElement(createWrapper(node)));
          }
        }
        return result;
      }

      /**
       * Creates a printable wrapper for the given element.
       * @private
       * @param {Element} element The element.
       * @returns {Element} The wrapper.
       */
      function createWrapper(element) {
        var node,
        nodes = element.attributes,
          index = nodes.length,
          wrapper = element.ownerDocument.createElement(shivNamespace + ':' + element.nodeName);

        // copy element attributes to the wrapper
        while (index--) {
          node = nodes[index];
          node.specified && wrapper.setAttribute(node.nodeName, node.nodeValue);
        }
        // copy element styles to the wrapper
        wrapper.style.cssText = element.style.cssText;
        return wrapper;
      }

      /**
       * Shivs the given CSS text.
       * (eg. header{} becomes html5shiv\:header{})
       * @private
       * @param {String} cssText The CSS text to shiv.
       * @returns {String} The shived CSS text.
       */
      function shivCssText(cssText) {
        var pair,
        parts = cssText.split('{'),
          index = parts.length,
          reElements = RegExp('(^|[\\s,>+~])(' + getElements().join('|') + ')(?=[[\\s,>+~#.:]|$)', 'gi'),
          replacement = '$1' + shivNamespace + '\\:$2';

        while (index--) {
          pair = parts[index] = parts[index].split('}');
          pair[pair.length - 1] = pair[pair.length - 1].replace(reElements, replacement);
          parts[index] = pair.join('}');
        }
        return parts.join('{');
      }

      /**
       * Removes the given wrappers, leaving the original elements.
       * @private
       * @params {Array} wrappers An array of printable wrappers.
       */
      function removeWrappers(wrappers) {
        var index = wrappers.length;
        while (index--) {
          wrappers[index].removeNode();
        }
      }

      /*--------------------------------------------------------------------------*/

      /**
       * Shivs the given document for print.
       * @memberOf html5
       * @param {Document} ownerDocument The document to shiv.
       * @returns {Document} The shived document.
       */
      function shivPrint(ownerDocument) {
        var shivedSheet,
        wrappers,
        data = getExpandoData(ownerDocument),
          namespaces = ownerDocument.namespaces,
          ownerWindow = ownerDocument.parentWindow;

        if (!supportsShivableSheets || ownerDocument.printShived) {
          return ownerDocument;
        }
        if (typeof namespaces[shivNamespace] == 'undefined') {
          namespaces.add(shivNamespace);
        }

        function removeSheet() {
          clearTimeout(data._removeSheetTimer);
          if (shivedSheet) {
            shivedSheet.removeNode(true);
          }
          shivedSheet= null;
        }

        ownerWindow.attachEvent('onbeforeprint', function() {

          removeSheet();

          var imports,
          length,
          sheet,
          collection = ownerDocument.styleSheets,
            cssText = [],
            index = collection.length,
            sheets = Array(index);

          // convert styleSheets collection to an array
          while (index--) {
            sheets[index] = collection[index];
          }
          // concat all style sheet CSS text
          while ((sheet = sheets.pop())) {
            // IE does not enforce a same origin policy for external style sheets...
            // but has trouble with some dynamically created stylesheets
            if (!sheet.disabled && reMedia.test(sheet.media)) {

              try {
                imports = sheet.imports;
                length = imports.length;
              } catch(er){
                length = 0;
              }

              for (index = 0; index < length; index++) {
                sheets.push(imports[index]);
              }

              try {
                cssText.push(sheet.cssText);
              } catch(er){}
            }
          }

          // wrap all HTML5 elements with printable elements and add the shived style sheet
          cssText = shivCssText(cssText.reverse().join(''));
          wrappers = addWrappers(ownerDocument);
          shivedSheet = addStyleSheet(ownerDocument, cssText);

        });

        ownerWindow.attachEvent('onafterprint', function() {
          // remove wrappers, leaving the original elements, and remove the shived style sheet
          removeWrappers(wrappers);
          clearTimeout(data._removeSheetTimer);
          data._removeSheetTimer = setTimeout(removeSheet, 500);
        });

        ownerDocument.printShived = true;
        return ownerDocument;
      }

      /*--------------------------------------------------------------------------*/

      // expose API
      html5.type += ' print';
      html5.shivPrint = shivPrint;

      // shiv for print
      shivPrint(document);

      if(typeof module == 'object' && module.exports){
        module.exports = html5;
      }

    }(typeof window !== "undefined" ? window : this, document));
  }

  ;


  /**
   * contains checks to see if a string contains another string
   *
   * @access private
   * @function contains
   * @param {string} str - The string we want to check for substrings
   * @param {string} substr - The substring we want to search the first string for
   * @returns {boolean}
   */

  function contains(str, substr) {
    return !!~('' + str).indexOf(substr);
  }

  ;

  /**
   * createElement is a convenience wrapper around document.createElement. Since we
   * use createElement all over the place, this allows for (slightly) smaller code
   * as well as abstracting away issues with creating elements in contexts other than
   * HTML documents (e.g. SVG documents).
   *
   * @access private
   * @function createElement
   * @returns {HTMLElement|SVGElement} An HTML or SVG element
   */

  function createElement() {
    if (typeof document.createElement !== 'function') {
      // This is the case in IE7, where the type of createElement is "object".
      // For this reason, we cannot call apply() as Object is not a Function.
      return document.createElement(arguments[0]);
    } else if (isSVG) {
      return document.createElementNS.call(document, 'http://www.w3.org/2000/svg', arguments[0]);
    } else {
      return document.createElement.apply(document, arguments);
    }
  }

  ;

  /**
   * Create our "modernizr" element that we do most feature tests on.
   *
   * @access private
   */

  var modElem = {
    elem: createElement('modernizr')
  };

  // Clean up this element
  Modernizr._q.push(function() {
    delete modElem.elem;
  });

  

  var mStyle = {
    style: modElem.elem.style
  };

  // kill ref for gc, must happen before mod.elem is removed, so we unshift on to
  // the front of the queue.
  Modernizr._q.unshift(function() {
    delete mStyle.style;
  });

  

  /**
   * getBody returns the body of a document, or an element that can stand in for
   * the body if a real body does not exist
   *
   * @access private
   * @function getBody
   * @returns {HTMLElement|SVGElement} Returns the real body of a document, or an
   * artificially created element that stands in for the body
   */

  function getBody() {
    // After page load injecting a fake body doesn't work so check if body exists
    var body = document.body;

    if (!body) {
      // Can't use the real body create a fake one.
      body = createElement(isSVG ? 'svg' : 'body');
      body.fake = true;
    }

    return body;
  }

  ;

  /**
   * injectElementWithStyles injects an element with style element and some CSS rules
   *
   * @access private
   * @function injectElementWithStyles
   * @param {string} rule - String representing a css rule
   * @param {function} callback - A function that is used to test the injected element
   * @param {number} [nodes] - An integer representing the number of additional nodes you want injected
   * @param {string[]} [testnames] - An array of strings that are used as ids for the additional nodes
   * @returns {boolean}
   */

  function injectElementWithStyles(rule, callback, nodes, testnames) {
    var mod = 'modernizr';
    var style;
    var ret;
    var node;
    var docOverflow;
    var div = createElement('div');
    var body = getBody();

    if (parseInt(nodes, 10)) {
      // In order not to give false positives we create a node for each test
      // This also allows the method to scale for unspecified uses
      while (nodes--) {
        node = createElement('div');
        node.id = testnames ? testnames[nodes] : mod + (nodes + 1);
        div.appendChild(node);
      }
    }

    style = createElement('style');
    style.type = 'text/css';
    style.id = 's' + mod;

    // IE6 will false positive on some tests due to the style element inside the test div somehow interfering offsetHeight, so insert it into body or fakebody.
    // Opera will act all quirky when injecting elements in documentElement when page is served as xml, needs fakebody too. #270
    (!body.fake ? div : body).appendChild(style);
    body.appendChild(div);

    if (style.styleSheet) {
      style.styleSheet.cssText = rule;
    } else {
      style.appendChild(document.createTextNode(rule));
    }
    div.id = mod;

    if (body.fake) {
      //avoid crashing IE8, if background image is used
      body.style.background = '';
      //Safari 5.13/5.1.4 OSX stops loading if ::-webkit-scrollbar is used and scrollbars are visible
      body.style.overflow = 'hidden';
      docOverflow = docElement.style.overflow;
      docElement.style.overflow = 'hidden';
      docElement.appendChild(body);
    }

    ret = callback(div, rule);
    // If this is done after page load we don't want to remove the body so check if body exists
    if (body.fake) {
      body.parentNode.removeChild(body);
      docElement.style.overflow = docOverflow;
      // Trigger layout so kinetic scrolling isn't disabled in iOS6+
      docElement.offsetHeight;
    } else {
      div.parentNode.removeChild(div);
    }

    return !!ret;

  }

  ;

  /**
   * domToCSS takes a camelCase string and converts it to kebab-case
   * e.g. boxSizing -> box-sizing
   *
   * @access private
   * @function domToCSS
   * @param {string} name - String name of camelCase prop we want to convert
   * @returns {string} The kebab-case version of the supplied name
   */

  function domToCSS(name) {
    return name.replace(/([A-Z])/g, function(str, m1) {
      return '-' + m1.toLowerCase();
    }).replace(/^ms-/, '-ms-');
  }
  ;

  /**
   * nativeTestProps allows for us to use native feature detection functionality if available.
   * some prefixed form, or false, in the case of an unsupported rule
   *
   * @access private
   * @function nativeTestProps
   * @param {array} props - An array of property names
   * @param {string} value - A string representing the value we want to check via @supports
   * @returns {boolean|undefined} A boolean when @supports exists, undefined otherwise
   */

  // Accepts a list of property names and a single value
  // Returns `undefined` if native detection not available
  function nativeTestProps(props, value) {
    var i = props.length;
    // Start with the JS API: http://www.w3.org/TR/css3-conditional/#the-css-interface
    if ('CSS' in window && 'supports' in window.CSS) {
      // Try every prefixed variant of the property
      while (i--) {
        if (window.CSS.supports(domToCSS(props[i]), value)) {
          return true;
        }
      }
      return false;
    }
    // Otherwise fall back to at-rule (for Opera 12.x)
    else if ('CSSSupportsRule' in window) {
      // Build a condition string for every prefixed variant
      var conditionText = [];
      while (i--) {
        conditionText.push('(' + domToCSS(props[i]) + ':' + value + ')');
      }
      conditionText = conditionText.join(' or ');
      return injectElementWithStyles('@supports (' + conditionText + ') { #modernizr { position: absolute; } }', function(node) {
        return getComputedStyle(node, null).position == 'absolute';
      });
    }
    return undefined;
  }
  ;

  /**
   * cssToDOM takes a kebab-case string and converts it to camelCase
   * e.g. box-sizing -> boxSizing
   *
   * @access private
   * @function cssToDOM
   * @param {string} name - String name of kebab-case prop we want to convert
   * @returns {string} The camelCase version of the supplied name
   */

  function cssToDOM(name) {
    return name.replace(/([a-z])-([a-z])/g, function(str, m1, m2) {
      return m1 + m2.toUpperCase();
    }).replace(/^-/, '');
  }
  ;

  // testProps is a generic CSS / DOM property test.

  // In testing support for a given CSS property, it's legit to test:
  //    `elem.style[styleName] !== undefined`
  // If the property is supported it will return an empty string,
  // if unsupported it will return undefined.

  // We'll take advantage of this quick test and skip setting a style
  // on our modernizr element, but instead just testing undefined vs
  // empty string.

  // Property names can be provided in either camelCase or kebab-case.

  function testProps(props, prefixed, value, skipValueTest) {
    skipValueTest = is(skipValueTest, 'undefined') ? false : skipValueTest;

    // Try native detect first
    if (!is(value, 'undefined')) {
      var result = nativeTestProps(props, value);
      if (!is(result, 'undefined')) {
        return result;
      }
    }

    // Otherwise do it properly
    var afterInit, i, propsLength, prop, before;

    // If we don't have a style element, that means we're running async or after
    // the core tests, so we'll need to create our own elements to use

    // inside of an SVG element, in certain browsers, the `style` element is only
    // defined for valid tags. Therefore, if `modernizr` does not have one, we
    // fall back to a less used element and hope for the best.
    var elems = ['modernizr', 'tspan'];
    while (!mStyle.style) {
      afterInit = true;
      mStyle.modElem = createElement(elems.shift());
      mStyle.style = mStyle.modElem.style;
    }

    // Delete the objects if we created them.
    function cleanElems() {
      if (afterInit) {
        delete mStyle.style;
        delete mStyle.modElem;
      }
    }

    propsLength = props.length;
    for (i = 0; i < propsLength; i++) {
      prop = props[i];
      before = mStyle.style[prop];

      if (contains(prop, '-')) {
        prop = cssToDOM(prop);
      }

      if (mStyle.style[prop] !== undefined) {

        // If value to test has been passed in, do a set-and-check test.
        // 0 (integer) is a valid property value, so check that `value` isn't
        // undefined, rather than just checking it's truthy.
        if (!skipValueTest && !is(value, 'undefined')) {

          // Needs a try catch block because of old IE. This is slow, but will
          // be avoided in most cases because `skipValueTest` will be used.
          try {
            mStyle.style[prop] = value;
          } catch (e) {}

          // If the property value has changed, we assume the value used is
          // supported. If `value` is empty string, it'll fail here (because
          // it hasn't changed), which matches how browsers have implemented
          // CSS.supports()
          if (mStyle.style[prop] != before) {
            cleanElems();
            return prefixed == 'pfx' ? prop : true;
          }
        }
        // Otherwise just return true, or the property name if this is a
        // `prefixed()` call
        else {
          cleanElems();
          return prefixed == 'pfx' ? prop : true;
        }
      }
    }
    cleanElems();
    return false;
  }

  ;

  /**
   * testProp() investigates whether a given style property is recognized
   * Property names can be provided in either camelCase or kebab-case.
   *
   * @memberof Modernizr
   * @name Modernizr.testProp
   * @access public
   * @optionName Modernizr.testProp()
   * @optionProp testProp
   * @function testProp
   * @param {string} prop - Name of the CSS property to check
   * @param {string} [value] - Name of the CSS value to check
   * @param {boolean} [useValue] - Whether or not to check the value if @supports isn't supported
   * @returns {boolean}
   * @example
   *
   * Just like [testAllProps](#modernizr-testallprops), only it does not check any vendor prefixed
   * version of the string.
   *
   * Note that the property name must be provided in camelCase (e.g. boxSizing not box-sizing)
   *
   * ```js
   * Modernizr.testProp('pointerEvents')  // true
   * ```
   *
   * You can also provide a value as an optional second argument to check if a
   * specific value is supported
   *
   * ```js
   * Modernizr.testProp('pointerEvents', 'none') // true
   * Modernizr.testProp('pointerEvents', 'penguin') // false
   * ```
   */

  var testProp = ModernizrProto.testProp = function(prop, value, useValue) {
    return testProps([prop], undefined, value, useValue);
  };
  

  /**
   * fnBind is a super small [bind](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/bind) polyfill.
   *
   * @access private
   * @function fnBind
   * @param {function} fn - a function you want to change `this` reference to
   * @param {object} that - the `this` you want to call the function with
   * @returns {function} The wrapped version of the supplied function
   */

  function fnBind(fn, that) {
    return function() {
      return fn.apply(that, arguments);
    };
  }

  ;
/*!
{
  "name": "ES5 Array",
  "property": "es5array",
  "notes": [{
    "name": "ECMAScript 5.1 Language Specification",
    "href": "http://www.ecma-international.org/ecma-262/5.1/"
  }],
  "polyfills": ["es5shim"],
  "authors": ["Ron Waldon (@jokeyrhyme)"],
  "tags": ["es5"]
}
!*/
/* DOC
Check if browser implements ECMAScript 5 Array per specification.
*/

  Modernizr.addTest('es5array', function() {
    return !!(Array.prototype &&
      Array.prototype.every &&
      Array.prototype.filter &&
      Array.prototype.forEach &&
      Array.prototype.indexOf &&
      Array.prototype.lastIndexOf &&
      Array.prototype.map &&
      Array.prototype.some &&
      Array.prototype.reduce &&
      Array.prototype.reduceRight &&
      Array.isArray);
  });

/*!
{
  "name": "ES6 Array",
  "property": "es6array",
  "notes": [{
    "name": "unofficial ECMAScript 6 draft specification",
    "href": "https://people.mozilla.org/~jorendorff/es6-draft.html"
  }],
  "polyfills": ["es6shim"],
  "authors": ["Ron Waldon (@jokeyrhyme)"],
  "warnings": ["ECMAScript 6 is still a only a draft, so this detect may not match the final specification or implementations."],
  "tags": ["es6"]
}
!*/
/* DOC
Check if browser implements ECMAScript 6 Array per specification.
*/

  Modernizr.addTest('es6array', !!(Array.prototype &&
    Array.prototype.copyWithin &&
    Array.prototype.fill &&
    Array.prototype.find &&
    Array.prototype.findIndex &&
    Array.prototype.keys &&
    Array.prototype.entries &&
    Array.prototype.values &&
    Array.from &&
    Array.of));

/*!
{
  "name": "ES6 String",
  "property": "es6string",
  "notes": [{
    "name": "unofficial ECMAScript 6 draft specification",
    "href": "https://people.mozilla.org/~jorendorff/es6-draft.html"
  }],
  "polyfills": ["es6shim"],
  "authors": ["Ron Waldon (@jokeyrhyme)"],
  "warnings": ["ECMAScript 6 is still a only a draft, so this detect may not match the final specification or implementations."],
  "tags": ["es6"]
}
!*/
/* DOC
Check if browser implements ECMAScript 6 String per specification.
*/

  Modernizr.addTest('es6string', !!(String.fromCodePoint &&
    String.raw &&
    String.prototype.codePointAt &&
    String.prototype.repeat &&
    String.prototype.startsWith &&
    String.prototype.endsWith &&
    String.prototype.contains));


  // Run each test
  testRunner();

  delete ModernizrProto.addTest;
  delete ModernizrProto.addAsyncTest;

  // Run the things that are supposed to run after the tests
  for (var i = 0; i < Modernizr._q.length; i++) {
    Modernizr._q[i]();
  }

  // Leak Modernizr namespace
  window.Modernizr = Modernizr;



/**
 * @fileoverview
 *
 * This file defines the pager module. The API
 * consists of two components, Random Access
 * and Sequential Access pager: the former only
 * allows to move by pages, but pages non-adjacent
 * to the current one can be selected; the latter
 * lets you move buth by single item and by page,
 * but only sequentially in both directions
 */

angular.module('pager', [])
/**
 * @fileoverview
 *
 * This service defines useful methods to
 * manage circular array 0-based indexes,
 * such as incrementing and decrementing
 * size-wisely.
 */


.service('CircularMovements', function() {

	/**
	 * This method handles all the effective work:
	 * moves and index circularly, both forward
	 * and backward, given start position, offset
	 * and upper bound index.
	 *
	 * @summary Moves and index circularly.
	 *
	 * @private
	 * @memberof CircularMovements.
	 *
	 * @param {int} offset - How much start will be moved: can be both positive and negative.
	 * @param {int} start - Initial index position, that will be moved by offset positions.
	 * @param {int} upperBound - Upper bound value for returned index, can be thought as array length.
	 * @return {int} start index moved circularly by offset having as upper bound upperBound.
	 */
	var circularlyMove = function(offset, start, upperBound) {
		return (start + offset % upperBound + upperBound) % upperBound;
	};

	/**
	 * @summary Moves an index backward by the given offset,
	 * with upperBound as upper bound for returned index.
	 *
	 * @memberof CircularMovements.
	 *
	 * @param {int} currentItem - Initial index position, that will be moved by offset positions.
	 * @param {int} offset - How much currentItem will be moved backwards: must be positive in order to work properly.
	 * @param {int} upperBound - Upper bound value for returned index, can be thought as array length.
	 * @return {int} start index moved backward circularly by offset having as upper bound upperBound.
	 */
	this.moveBackByMany = function(offset, currentItem,
				upperBound) {
		return circularlyMove(-offset, currentItem,
				upperBound);
	};

	/**
	 * @summary Moves an index backward by one, with upperBound
	 * as upper bound for returned index.
	 *
	 * @memberof CircularMovements.
	 *
	 * @param {int} currentItem - Initial index position, that will be moved by offset positions.
	 * @param {int} upperBound - Upper bound value for returned index, can be thought as array length.
	 * @return {int} start index moved backward circularly by one having as upper bound upperBound.
	 */
	this.moveBackByOne = angular.bind(this, this.moveBackByMany, 1);

	/**
	 * @summary Moves an index forward by the given offset,
	 * with upperBound as upper bound for returned index.
	 *
	 * @memberof CircularMovements.
	 *
	 * @param {int} currentItem - Initial index position, that will be moved by offset positions.
	 * @param {int} offset - How much currentItem will be moved forward: must be positive in order to work properly.
	 * @param {int} upperBound - Upper bound value for returned index, can be thought as array length.
	 * @return {int} start index moved forward circularly by offset having as upper bound upperBound.
	 */
	this.moveForwardByMany = circularlyMove;

	/**
	 * @summary Moves an index forward by one, with upperBound
	 * as upper bound for returned index.
	 *
	 * @memberof CircularMovements.
	 *
	 * @param {int} currentItem - Initial index position, that will be moved by offset positions.
	 * @param {int} upperBound - Upper bound value for returned index, can be thought as array length.
	 * @return {int} start index moved forward circularly by one having as upper bound upperBound.
	 */
	this.moveForwardByOne = angular.bind(this, this.moveForwardByMany, 1);

	/**
	 * @summary Sets the index circularly.
	 *
	 * @memberof CircularMovements.
	 *
	 * @param {int} position - Desired value for index: will wrap if too large.
	 * @param {int} upperBound - Upper bound value for returned index, can be thought as array length.
	 * @return {int} The index value, unchanged if small enough, wrapped if too large.
	 */
	this.setPosition = function(position, upperBound) {
		return circularlyMove(position, 0, upperBound);
	};
})
/**
 * @fileoverview
 *
 * This component is meant for items set where
 * pages are not fixed, that is the first element
 * of each page may change index within the array.
 * This prevents from moving randomly, but makes
 * possible to move sequentially by both single
 * item and page.
 *
 * The visual part is made up of fur buttons, to
 * move to previous and next item, and to previous
 * and next page, sort of rewind and fast forward.
 */


.component('sequentialAccessPager', {
	controllerAs: 'model',
	templateUrl: '/util/html/sequential-access-pager.html',

	bindings: {
		currentItem: '<',
		pageLength: '<',
		itemsCount: '<',

		onItemChange: '&',
		onPageLengthChange: '&'
	},

	controller: ['CircularMovements', function(circMov) {

		/**
		 * @summary Returns true when items make
		 * up at least two pages.
		 *
		 * @return {boolean}
		 */
		this.isPaginable = function() {
			return this.itemsCount > this.pageLength;
		};

		/**
		 * @summary Moves the current page back by one, or
		 * alternatively, current item back by page length.
		 *
		 * @return {SequentialAccessPager} This instance.
		 */
		this.rewind = function() {
			this.currentItem = circMov.moveBackByMany(this.pageLength,
					this.currentItem, this.itemsCount);
			this.onItemChange({newItem: this.currentItem});
			return this;
		};

		/**
		 * @summary Moves the current item back by one.
		 *
		 * @return {SequentialAccessPager} This instance.
		 */
		this.prev = function() {
			this.currentItem = circMov.moveBackByOne(this.currentItem,
					this.itemsCount);
			this.onItemChange({newItem: this.currentItem});
			return this;
		};

		/**
		 * @summary Moves the current item forward by one.
		 *
		 * @return {SequentialAccessPager} This instance.
		 */
		this.next = function() {
			this.currentItem = circMov.moveForwardByOne(this.currentItem,
					this.itemsCount);
			this.onItemChange({newItem: this.currentItem});
			return this;
		};

		/**
		 * @summary Moves the current page forward by one, or
		 * alternatively, current item forward by page length.
		 *
		 * @return {SequentialAccessPager} This instance.
		 */
		this.fastForward = function() {
			this.currentItem = circMov.moveForwardByMany(this.pageLength,
					this.currentItem, this.itemsCount);
			this.onItemChange({newItem: this.currentItem});
			return this;
		};
	}]
});


/**
 * @fileoverview
 *
 * This file contains the definition of the
 * this website AngularJS module.
 */

angular.module('l42y.sprintf', [
]).filter('sprintf', function (
	$window
) {
	return function () {
		return $window.sprintf.apply(this, arguments);
	};
}).filter('vsprintf', function (
	$window
) {
	return function (format, array) {
		return $window.vsprintf(format, array);
	};
});

angular.module('dragonSearch', [
	'ui.select',
	'ngSanitize',
	'angular-md5',
	'angularMoment',
	'l42y.sprintf',
	'pager'
])
/**
 * @fileoverview
 *
 * This file contains the configuration blocks
 * for this website AngularJS module.
 */


// Global configuration of ui-select plugin
.config(['uiSelectConfig', function(uiSelect) {
	uiSelect.appendToBody = false;
	uiSelect.resetSearchInput = true;
	uiSelect.searchEnabled = true;
	uiSelect.theme = 'select2';
}])
/**
 * @fileoverview
 *
 * This file contains the run blocks for this
 * website AngularJS module, particularly
 * polyfill loading through AJAX and Modernizr.
 */


/*
	This constant is only used here by now,
	and this situation very lileky to stay
	this way, so it's pointless to define
	it elsewhere.
*/
.constant('Modernizr', Modernizr)

/*
	This run block loads the polyfills needed
	by every component of the application,
	using Modernizr for feature detection and
	JSONP AJAX requests to retrieve shims.
*/
.run(['Modernizr', '$http', function(Modernizr, http) {
	if (!Modernizr.es6string)
		http.jsonp('/util/js/polyfills/String.startsWith.js');

	if (!Modernizr.es6array)
		http.jsonp('/util/js/polyfills/Array.findIndex.js');

	if (!Modernizr.es5array)
		http.jsonp('/util/js/polyfills/Array.map.js');
}])
/**
 * @fileoverview
 *
 * This filter is meant as a circular version of
 * AngularJS built-in limitTo filter: when one
 * end of the input array is reached, but less
 * elements than requested would be returned,
 * it just gets them wrapping to the other end,
 * stopping where it begun at most.
 *
 * Mind that this is still a filter, so an array
 * having more elements than the input, meaning
 * that it has duplicates, will never be returned.
 * For example, asking for 7 elements when source
 * only has 3 will return a 3-element-long array.
 *
 * @see {https://docs.angularjs.org/api/ng/filter/limitTo AngularJS built-in limitTo filter}.
 */


.filter('circularLimitTo', ['limitToFilter', function(limitTo) {
	return function(input, limit, begin) {
		var subInput = limitTo(input, limit, begin);

		// Limit can be negative
		var absLimit = Math.abs(limit);

		/*
			This also handles the case in which begin is 0,
			regardless of limit, because, if starting from 0,
			limitTo returns when either all or enough elements
			are taken from input, that is the if condition;
			moreover, the case when limit is negative and begin
			is positive is included too, due to limitTo setting
			the latter to 0.
		*/
		if (subInput.length == absLimit
				|| subInput.length == input.length)
			return subInput;

		/*
			Math.min us used to avoid taking more elements
			than input actually holds.
		*/
		var missingCount = Math.min(absLimit, input.length)
				- subInput.length;

		/*
			When limit is negative it must wrap to the end
			of the array, that is achieved via passing down
			to limitTo a negative second argument
		*/
		return subInput.concat(limitTo(input, limit < 0 ?
				-missingCount : missingCount));
	};
}])
/**
 * @fileoverview
 *
 * This service defines methods that operate with
 * time durations: they can be reduced/increased
 * by 20% and days can be separetely displayed or
 * added to hours. All this is achieved thanks to
 * {@link http://momentjs.com/docs/#/durations/ moment.js duration class}
 * and {@link https://github.com/alexei/sprintf.js sprintf.js}.
 */


.service('TimeTweak', ['sprintfFilter', 'moment', function(sprintf, moment) {
	var vm = this;

	/**
	 * @summary sprintf format that displays days.
	 *
	 * @private
	 * @memberof TimeTweak.
	 */
	var daysfulFormat = '%02d:%02d:%02d:%02d';

	/**
	 * @summary sprintf format that doesn't display days.
	 *
	 * @private
	 * @memberof TimeTweak.
	 */
	var dayslessFormat = '%02d:%02d:%02d';

	/**
	 * This method creates a moment.duration instance
	 * from a colon-separed time duration string, in
	 * either 'dd:HH:mm:ss' or 'HH:mm:ss' format. If
	 * the input already is a moment.duration object,
	 * it is left untouched.
	 *
	 * @summary Creates a moment.duration object from
	 * a time duration string.
	 *
	 * @private
	 * @memberof TimeTweak.
	 *
	 * @param {string|moment.duration} time - Input time duration string, in either 'dd:HH:mm:ss' or 'HH:mm:ss' format.
	 * @return {moment.duration} A moment.duration instance derived from input.
	 *
	 * @see {@link http://momentjs.com/docs/#/durations/ moment.js duration class}.
	 */
	var makeDuration = function(time) {
		if (moment.isDuration(time))
			return time;

		/*
			Days are present, so transforming string
			according to moment.js specifications.
			http://momentjs.com/docs/#/durations/creating/
		*/
		if (typeof(time) == 'string' && vm.daysAreDisplayed(time))
			time = time.replace(':', '.');

		return moment.duration(time);
	};

	/**
	 * This method formats a time duration to either
	 * 'dd:HH:mm:ss' or HH:mm:ss' format: in other
	 * words days are either displayed or converted
	 * to hours.
	 *
	 * @summary Formats a time duration to either
	 * 'dd:HH:mm:ss' or HH:mm:ss' format.
	 *
	 * @private
	 * @memberof TimeTweak.
	 *
	 * @param {boolean} putDays - When true, the result will be in 'dd:HH:mm:ss' format, but days will be hidden if none. When false, 'HH:mm:ss' format will be used.
	 * @param {string|moment.duration} time - Input time duration: when string, only 'dd:HH:mm:ss' and 'HH:mm:ss' format are accepted.
	 * @return {string} Time duration string in either 'dd:HH:mm:ss' or HH:mm:ss' format.
	 *
	 * @see {@link http://momentjs.com/docs/#/durations/ moment.js duration class}.
	 */
	var format = function(putDays, time) {
		time = makeDuration(time);

		/*
			moment.duration().as*() methods all return
			doubles: truncation is handled by sprintf
			due to %d format.
		*/
		var daysCount = time.asDays();
		if (putDays && daysCount >= 1)
			return sprintf(daysfulFormat, daysCount, time.hours(),
					time.minutes(), time.seconds());
		return sprintf(dayslessFormat, time.asHours(),
				time.minutes(), time.seconds());
	};

	/**
	 * This method multiplies the supplied time duration by
	 * a given value: the output format can either be
	 * explicitly provided or inferred from the input itself.
	 *
	 * @summary Multiplies time durations by a value.
	 *
	 * @private
	 * @memberof TimeTweak.
	 *
	 * @param {number} multiplier - Value the time duration will be multiplied by.
	 * @param {string} time - Input time duration: only 'dd:HH:mm:ss' and 'HH:mm:ss' formats are accepted.
	 * @param {boolean} [putDays] - If true, days will be displayed in the result, if any. When false, days will be converted to hours. If undefined, output format will be deduced from input.
	 * @return {string} The new time duration.
	 */
	var tweakTime = function(multiplier, time, putDays) {
		if (arguments.length < 3)
			putDays = vm.daysAreDisplayed(time);

		return format(putDays, moment.duration(makeDuration(time)
				.asMilliseconds() * multiplier));
	};

	/**
	 * @summary Returns true when a time displays days.
	 *
	 * @memberof TimeTweak.
	 *
	 * @param {string} time - Input time string.
	 * @return {boolean} True if input time string displays days.
	 */
	vm.daysAreDisplayed = function(time) {
		return time.length > 8;
	};

	/**
	 * This method accepts a colon-separed time duration
	 * string, in either 'dd:HH:mm:ss' or 'HH:mm:ss' format,
	 * and returns another one of the same duration but
	 * with days displayed, that is the former format, only
	 * when there is at least one.
	 *
	 * @summary Displays days in the passed time duration string.
	 *
	 * @memberof TimeTweak.
	 *
	 * @param {string} time - Input time duration string, in either 'dd:HH:mm:ss' or 'HH:mm:ss' format.
	 * @return {string} Time duration string in 'dd:HH:mm:ss' format, with no days if none in input.
	 */
	vm.displayDays = angular.bind(undefined, format, true);

	/**
	 * This method accepts a colon-separed time duration
	 * string, in either 'dd:HH:mm:ss' or 'HH:mm:ss' format,
	 * and returns another one of the same duration but
	 * with days converted to hours, that is the latter format.
	 *
	 * @summary Convert days into hours in the provided
	 * time duration string.
	 *
	 * @memberof TimeTweak.
	 *
	 * @param {string} time - Input time duration string, in either 'dd:HH:mm:ss' or 'HH:mm:ss' format.
	 * @return {string} Time duration string in 'HH:mm:ss' format.
	 */
	vm.convertDays = angular.bind(undefined, format, false);

	/**
	 * This method accepts a colon-separed time duration
	 * string, in either 'dd:HH:mm:ss' or 'HH:mm:ss' format,
	 * and returns another reduced by 20%, in the same
	 * format as the input.
	 *
	 * @summary Reduces a time duration by 20%.
	 *
	 * @memberof TimeTweak.
	 *
	 * @param {string} time - Input time duration string, in either 'dd:HH:mm:ss' or 'HH:mm:ss' format.
	 * @return {string} Time duration string reduced by 20%.
	 */
	vm.reduce = angular.bind(undefined, tweakTime, 0.8);

	/**
	 * This method accepts a colon-separed time duration
	 * string, in either 'dd:HH:mm:ss' or 'HH:mm:ss' format,
	 * and returns another increased by 20%, in the same
	 * format as the input.
	 *
	 * @summary Increases a time duration by 20%.
	 *
	 * @memberof TimeTweak.
	 *
	 * @param {string} time - Input time duration string, in either 'dd:HH:mm:ss' or 'HH:mm:ss' format.
	 * @return {string} Time duration string increased by 20%.
	 */
	vm.increase = angular.bind(undefined, tweakTime, 1.25);
}])
/**
 * @fileoverview
 *
 * This service performs time durations tasks,
 * by means of timeTweak service, on an array
 * of Time objects. Said tasks are only carried
 * out once, sice the results are cached.
 *
 * @see timeTweak
 * @see Time
 */


.service('TimeManager', ['TimeTweak', function(timeTweak) {
	var vm = this;

	/**
	 * @class
	 *
	 * @summary Constructs a new Data object with given
	 * time duration string and initial status.
	 *
	 * @classdesc This class holds all data necessary
	 * for TimeManager class to perform tasks, namely
	 * time status and cache.
	 *
	 * @private
	 * @memberof TimeManager.
	 *
	 * @prop {boolean} reduced - Indicates the current reduced/full status of the time duration.
	 * @prop {boolean} displayDays - Indicates whether the time currently shows days.
	 *
	 * @param {string} time - Time duration string to be cached.
	 * @param {boolean} reduced - True if the duration is reduced, will be set as initial status.
	 * @param {boolean} displayDays - True if the duration shows days, will be set as initial status.
	 */
	var Data = function(time, reduced, displayDays) {
		this.reduced = reduced;
		this.displayDays = displayDays;
		this.cache = {};

		this.addToCache(time);
	};

	/**
	 * @summary Returns cache keys for the current status.
	 *
	 * @private
	 *
	 * @typedef {object} CacheKeys
	 * @prop {string} duration - First-level-of-nesting cache key.
	 * @prop {string} format - Second-level-of-nesting cache key.
	 *
	 * @return {CacheKeys} An object containing both cache keys.
	 */
	Data.prototype.getCurrentCacheKeys = function() {
		return {
			duration: this.reduced ? 'reduced' : 'full',
			format: this.displayDays ? 'days' : 'noDays'
		};
	};

	/**
	 * This method adds a time string to the cache,
	 * indexing it basing on current status: the
	 * insertion is actually performed only if said
	 * index has no value. The cached time string
	 * is the first argument itself when it is the
	 * only one, otherwise it is retrieved by calling
	 * the supplied method of timeTweak with the
	 * first argument.
	 *
	 * @summary Adds a time string to the cache only when
	 * not already present.
	 *
	 * @param {string} sourceTime - The duration time string that will be cached when it's the only argument, the input of timeTweak method when there are two.
	 * @param {string} [method] - When provided, it's the timeTweak method that will be called to generate the cached time string.
	 * @return {TimeManager.Data} This instance, to allow chaining.
	 *
	 * @see timeTweak
	 */
	Data.prototype.addToCache = function(sourceTime, method) {
		var keys = this.getCurrentCacheKeys();

		// The first level of nesting is the duration, reduced/full
		if (!this.cache[keys.duration])
			this.cache[keys.duration] = {};

		// The second level of nesting is the format, days/noDays
		if (!this.cache[keys.duration][keys.format])
			this.cache[keys.duration][keys.format] = timeTweak[method] ?
					timeTweak[method](sourceTime) : sourceTime;

		return this;
	};

	/**
	 * @summary Returns the cached time corresponding
	 * to the current status.
	 *
	 * @return {string} The cached time of the current status.
	 */
	Data.prototype.getCurrentCachedTime = function() {
		var keys = this.getCurrentCacheKeys();

		return this.cache[keys.duration][keys.format];
	};

	/**
	 * @summary The Time object array all operations
	 * are performed on.
	 *
	 * @private
	 * @memberof TimeManager#
	 *
	 * @type {Time[]}
	 */
	vm.times = [];

	/**
	 * @summary Attaches a new TimeManager.Data object to a Time instance.
	 *
	 * @private
	 * @memberof TimeManager.
	 *
	 * @param {boolean} reduced - True if the duration is reduced, will be set as initial status.
	 * @param {boolean} displayDays - True if the duration shows days, will be set as initial status.
	 * @param {Time} time - Time instance data will be added to.
	 * @return {Time} The very same input Time instance, but with TimeManager data attached.
	 *
	 * @see TimeManager.Data
	 */
	var addData = function(reduced, displayDays, time) {
		return Object.defineProperty(time, 'TimeManager', {
			__proto__: null,
			configurable: false,
			enumarable: false,
			writable: false,
			value: new Data(time.time, reduced, displayDays)
		});
	};

	/**
	 * This method updates a status key of every Time
	 * instance of the internal collection to a new
	 * value. Consequently, the time duration string
	 * is updated, either by retrieving a cached value
	 * or by generating it using the supplied method
	 * of timeTweak service.
	 *
	 * @summary Updates status and time string duration
	 * of all internal Time instances.
	 *
	 * @private
	 * @memberof TimeManager#
	 *
	 * @param {string} method - The timeTweak method to call if the new time duration string is not cached.
	 * @param {string} status - The status key whose value will be updated.
	 * @param {boolean} newStatus - The new value of the status key.
	 *
	 * @see timeTweak
	 */
	var forEachTime = function(method, status, newStatus) {
		angular.forEach(vm.times, function(item) {
			var data = item.TimeManager;

			if (data[status] == newStatus)
				return;

			data[status] = newStatus;
			data.addToCache(item.time, method);

			item.time = data.getCurrentCachedTime();
		});
	};

	/**
	 * This method adds an array of Time instances to
	 * the internal collection. To allow some degree
	 * of flexibility, it can be also called with a
	 * single Time instances, that resolves to calling
	 * addTime() method. Finally, since it returns
	 * this instance, it is chainable.
	 *
	 * @summary Adds an array of Time instances to the array.
	 *
	 * @memberof TimeManager#
	 *
	 * @param {Time[]|Time} times - The times object that will be added. If a single one is passed, addTime() method is called.
	 * @param {boolean} reduced - When True, it means that all the passed durations are reduced.
	 * @param {boolean} displayDays - When True, it means that all the passed durations show days.
	 * @return {TimeManager} This instance.
	 */
	vm.addTimes = function(times, reduced, displayDays) {
		if (!angular.isArray(times))
			return vm.addTime(times, reduced, displayDays);

		vm.times = vm.times.concat(times.map(angular.bind(
					undefined, addData, reduced, displayDays)));
		return vm;
	};

	/**
	 * This method adds a single Time instance to the
	 * internal collection. To allow some degree of
	 * flexibility, it can be also called with an array
	 * of Time instances, that resolves to calling
	 * addTimes() method. Finally, since it returns
	 * this instance, it is chainable.
	 *
	 * @summary Adds a single Time instance to the array.
	 *
	 * @memberof TimeManager#
	 *
	 * @param {Time|Time[]} time - The time object that will be added. If an array is passed, addTimes() method is called.
	 * @param {boolean} reduced - True if the passed time is reduced.
	 * @param {boolean} displayDays - True if the passed time shows days.
	 * @return {TimeManager} This instance.
	 */
	vm.addTime = function(time, reduced, displayDays) {
		if (angular.isArray(time))
			return vm.addTimes(time, reduced, displayDays);

		vm.times.push(addData(reduced, displayDays, time));
		return vm;
	};

	/**
	 * @summary Reduces all durations by 20%, provided they are not already.
	 *
	 * @memberof TimeManager#
	 *
	 * @return {TimeManager} This instance.
	 */
	vm.reduce = function() {
		forEachTime('reduce', 'reduced', true);
		return vm;
	};

	/**
	 * @summary Increases all durations by 20%, provided they are not already.
	 *
	 * @memberof TimeManager#
	 *
	 * @return {TimeManager} This instance.
	 */
	vm.increase = function() {
		forEachTime('increase', 'reduced', false);
		return vm;
	};

	/**
	 * @summary Displays days on all durations, provided one lasts at least one.
	 *
	 * @memberof TimeManager#
	 *
	 * @return {TimeManager} This instance.
	 */
	vm.displayDays = function() {
		forEachTime('displayDays', 'displayDays', true);
		return vm;
	};

	/**
	 * @summary Converts days to hours on all durations.
	 *
	 * @memberof TimeManager#
	 *
	 * @return {TimeManager} This instance.
	 */
	vm.convertDays = function() {
		forEachTime('convertDays', 'displayDays', false);
		return vm;
	};
}])
/**
 * @fileoverview
 *
 * This service manages an array of Hint objects:
 * this includes tasks such as AJAX retrieval and
 * local recycle.
 * Also, new dragons are added to TimesManager,
 * since the time they carry ought to be tweakable.
 *
 * @see Hint
 * @see TimeManager
 */


.service('BreedingHints', ['$http', 'TimeManager', function(http, times) {
	var vm = this;

	/**
	 * @summary Array of managed Hints objects.
	 *
	 * @private
	 * @memberof BreedingHints#
	 */
	vm.hints = [];

	/**
	 * This method performs an AJAX request to get the breeding
	 * hint of the dragon whose id has been passed, placing it
	 * straight at the beginning of hints array. Also, hatching
	 * times of the required dragon and its possible parents are
	 * added to TimeMaganer. Returning an AngularJS promise
	 * instance, this method is chainable.
	 *
	 * @summary Requests a breeding hint through AJAX and places
	 * it at the top of hints array.
	 *
	 * @private
	 * @memberof BreedingHints.
	 *
	 * @param {int} id - Id of the dragon whose breeding hint will be retrieved.
	 * @param {boolean} reduced - When true, dragons hatching times will be reduced.
	 * @param {boolean} displayDays - When true, dragons hatching times will display days.
	 * @return {$q} AngularJS promise instance, to allow chaining.
	 *
	 * @see Hint
	 */
	var requestHint = function(id, reduced, displayDays) {
		return http.get('ajax.php', {params: {request: 'breed',
					id: id, reduced: reduced, displayDays: displayDays}})
			.success(function(hint) {

				// hint is expected to be an instance of Hint.
				vm.hints.unshift(hint);

				times.addTime(hint, reduced, displayDays);
				if (hint.parent1)
					times.addTime(hint.parent1, reduced, displayDays);
				if (hint.parent2)
					times.addTime(hint.parent2, reduced, displayDays);
			});
	};

	/**
	 * This method requests the breeding hint of a dragon:
	 * if it has been required previously, it's just moved
	 * to the top position, otherwise an AJAX request to
	 * get it is performed. This method is chainable, since
	 * it returns this instance.
	 *
	 * @summary Retrieves the breeding hint of the passed/selected
	 * dragon through AJAX, or moves it to the top if existing.
	 *
	 * @memberof BreedingHints#
	 *
	 * @param {int} id - Id of the dragon whose breeding hint will be retrieved.
	 * @param {boolean} reduced - When true, dragons hatching times will be reduced.
	 * @param {boolean} displayDays - When true, dragons hatching times will display days.
	 * @return {BreedingHints} This instance.
	 *
	 * @see Hint
	 */
	vm.newHint = function(id, reduced, displayDays) {
		var hintIndex = vm.hints.findIndex(function(hint) {
				return id == hint.id;
			});

		// Hint not found, requesting it through AJAX
		if (hintIndex == -1)
			requestHint(id, reduced, displayDays);

		// Hint found, but not first: moving to top
		else if (hintIndex)
			vm.hints.unshift(vm.hints.splice(hintIndex, 1)[0]);

		return vm;
	};

	/**
	 * This method returns true when the passed breeding hint
	 * is a basic breeding rule one: this is the default case,
	 * in other words no notes, no required breed elements and
	 * no parents.
	 *
	 * @summary Checks whether basic breeding rule is to be
	 * applied for the provided breeding hint.
	 *
	 * @memberof BreedingHints#
	 *
	 * @param {Hint} hint - The input breeding hint.
	 * @return {boolean} True when the passed hint is a basic breeding rule one.
	 */
	vm.isBasicBreedingRule = function(hint) {
		return !hint.notes && !hint.breedElems
				&& !hint.parent1 && !hint.parent2;
	};

	/**
	 * @summary Getter for hints property.
	 *
	 * @memberof BreedingHints#
	 *
	 * @return {Hint[]} hints property of this instance.
	 *
	 * @see Hint
	 */
	vm.getHints = function() {
		return vm.hints;
	};
}])
/**
 * @fileoverview
 *
 * This file contains the definition of the controller
 * for breeding hints page, BreedingHintsController.
 *
 * @see BreedingHints
 */


.controller('BreedingHintsController',
		['$http', 'BreedingHints', function(http, hints) {
	var vm = this;

	vm.reduced;						// Reduced time checkbox
	vm.displayDays;					// Display days checkbox
	vm.names;						// List of dragon names to populate the menu
	vm.dragon;						// Selected dragon
	vm.hints = hints.getHints();	// Currently loaded hints
	vm.currentHint = 0;				// Index of the first hint to be displayed
	vm.pageLength = 10;				// Hint page length

	// AJAX request to populate dragon names menu
	http.get('../php/ajax.php', {params: {request: 'breedInit'}})
	.success(function(names) {

		// names element are expected to have 'id' and 'name' properties.
		vm.names = names;
	});

	/**
	 * This method adds/moves to the top of hints collection
	 * the breeding hint of the passed/selected dragon,
	 * bringing it into view by setting its index as the
	 * currently displayed one.
	 *
	 * @summary Adds the breeding hint of the passed/selected
	 * dragon and brings it to view.
	 *
	 * @memberof BreedingHintsController#
	 *
	 * @param {int} [id=vm.dragon.id] - Id of the dragon whose breeding hint will be retrieved.
	 * @return {BreedingHintsController} This instance.
	 *
	 * @see Hint
	 * @see BreedingHints#requestHint
	 */
	vm.addHint = function(id) {
		hints.newHint(id || vm.dragon.id, vm.reduced,
				vm.displayDays);
		vm.setCurrentHint(0);
		return vm;
	};

	/**
	 * @summary Case-insensitive version of startsWith()
	 * method of JavaScript built-in String object.
	 *
	 * @memberof BreedingHintsController#
	 *
	 * @param {string} string - The string that will be scanned.
	 * @param {string} [substring] - The string that will be searched for.
	 * @return {boolean} True if string starts with substring.
	 */
	vm.startsWithCi = function(string, substring) {
		return string.toLowerCase().startsWith(
				substring.toLowerCase());
	};

	/**
	 * This method is a simple setter for the reduced property.
	 * Since it returns this instance, it is chainable.
	 *
	 * @summary Setter for reduced property.
	 *
	 * @memberof BreedingHintsController#
	 *
	 * @param {boolean} reduced - The new value of reduced property.
	 * @return {BreedingHintsController} This instance.
	 */
	vm.setReduced = function(reduced) {
		vm.reduced = reduced;
		return vm;
	};

	/**
	 * This method is a simple setter for the displayDays property.
	 * Since it returns this instance, it is chainable.
	 *
	 * @summary Setter for displayDays property.
	 *
	 * @memberof BreedingHintsController#
	 *
	 * @param {boolean} displayDays - The new value of displayDays property.
	 * @return {BreedingHintsController} This instance.
	 */
	vm.setDisplayDays = function(displayDays) {
		vm.displayDays = displayDays;
		return vm;
	};

	/**
	 * This method is a simple setter for the currentHint property.
	 * Since it returns this instance, it is chainable.
	 *
	 * @summary Setter for currentHint property.
	 *
	 * @memberof BreedingHintsController#
	 *
	 * @param {int} position - The new value of currentHint property.
	 * @return {BreedingHintsController} This instance.
	 */
	vm.setCurrentHint = function(position) {
		vm.currentHint = position;
		return vm;
	};

	/**
	 * This method is a simple setter for the pageLength property.
	 * Since it returns this instance, it is chainable.
	 *
	 * @summary Setter for pageLength property.
	 *
	 * @memberof BreedingHintsController#
	 *
	 * @param {int} length - The new value of pageLength property.
	 * @return {BreedingHintsController} This instance.
	 */
	vm.setPageLength = function(length) {
		vm.pageLength = length;
		return vm;
	};

	/**
	 * @summary Checks whether basic breeding rule is to be
	 * applied for the provided breeding hint.
	 *
	 * @memberof BreedingHintsController#
	 *
	 * @param {Hint} hint - The input breeding hint.
	 * @return {boolean} True when the passed hint is a basic breeding rule one.
	 *
	 * @see Hint
	 * @see BreedingHints#isBasicBreedingRule
	 */
	vm.isBasicBreedingRule = angular.bind(hints, hints.isBasicBreedingRule);
}])
/**
 * @fileoverview
 *
 * This component is roughly a GUI for TimeManager
 * service: it's made up of two checkboxes that
 * activate time reduction and days display when
 * checked.
 *
 * It has no explicit inputs, since it's actually
 * TimeManager that does the real work. The outputs
 * are two callbacks, onReduChange and onDdChange,
 * fired on every value change of reduced and
 * displayDays respectively: the former has the new
 * value in key 'redu', the latter in 'dd'. They
 * are also called in initializaton phase with
 * initial values.
 *
 * @see TimeManager
 */


.component('timeTweakBox', {
	controllerAs: 'model',
	templateUrl: '../html/time-tweak-box.html',

	bindings: {
		onReduChange: '&',
		onDdChange: '&'
	},

	controller: ['TimeManager', function(times) {
		this.reduced = false;		// Reduced time checkbox
		this.displayDays = false;	// Display days checkbox

		// Parent initialization
		this.onReduChange({redu: this.reduced});
		this.onDdChange({dd: this.displayDays});

		/**
		 * This method reduces/increases all times
		 * in TimeManager basing on the value of
		 * this.reduced.
		 *
		 * @summary Reduces/increases TimeManager times.
		 *
		 * @memberof TimeTweakBox#
		 *
		 * @return {TimeTweakBox} This instance.
		 */
		this.tweakTimes = function() {
			if (this.reduced)
				times.reduce();
			else
				times.increase();
			return this;
		};

		/**
		 * This method changes the format of all times
		 * in TimeManager basing on the value of
		 * this.displayDays.
		 *
		 * @summary Changes the format of TimeManager times.
		 *
		 * @memberof TimeTweakBox#
		 *
		 * @return {TimeTweakBox} This instance.
		 */
		this.toggleFormat = function() {
			if (this.displayDays)
				times.displayDays();
			else
				times.convertDays();
			return this;
		};
	}]
})
/**
 * @fileoverview
 *
 * This service provides methods that generate
 * Dragonvale Wiki image URLs of generic files,
 * eggs, adult dragons and elemental flags.
 */


.service('Image', ['md5', 'moment', function(md5, moment) {
	var vm = this;

	/**
	 * @summary Initial part of any returned URL.
	 *
	 * @private
	 * @memberof Image.
	 */
	var baseURL = '//vignette3.wikia.nocookie.net/dragonvale/images';

	/**
	 * @summary Seasons names, sorted by year's quarters.
	 *
	 * @private
	 * @memberof Image.
	 */
	var seasons = ['Winter', 'Spring', 'Summer', 'Autumn'];

	/**
	 * This function returns the capitalized english
	 * season name of the specified date, defaulting
	 * to current, with some approximations.
	 *
	 * @summary Returns the season name of the passed date.
	 *
	 * @private
	 * @memberof Image.
	 *
	 * @param {moment} [date=moment()] - The date whose season will be returned.
	 * @return {String} Capitalized english season name of the provided date.
	 *
	 * @see {@link http://momentjs.com/docs moment.js documentation}
	 */
	var getSeason = function(date) {
		if (!(date instanceof moment))
			date = moment();

		return seasons[date.quarter() - 1];
	};

	/**
	 * Object of functions to get the dragon pictures for
	 * Snowflake, Monolith and Seasonal dragons, since
	 * they're not the same ass the egg name: Seasonal
	 * has seasons in dragon picture, while Snowflake
	 * and Monolith share the same egg for all five of
	 * a kind.
	 *
	 * @summary Object of functions to get the dragon
	 * pictures for Snowflake, Monolith and Seasonal dragons.
	 *
	 * @private
	 * @memberof Image.
	 */
	var getWeirdDragonImg = {

		/**
		 * @summary Returns Dragonvale Wiki picture URL
		 * for Snowflake/Monolith dragons.
		 *
		 * @private
		 * @memberof Image.
		 *
		 * @param {string} name - Either 'Snowflake' or 'Monolith' followed by a number between 1 and 5.
		 * @param {string} eggName - Either 'Snowflake' or 'Monolith'.
		 * @return {string} Dragonvale Wiki picture URL of given Snowflake/Monolith dragon.
		 */
		Snowflake: function(name, eggName) {
			return vm.getImg(eggName + 'DragonAdult' + name.slice(-1) + '.png');
		},

		/**
		 * @summary Returns Dragonvale Wiki picture URL for
		 * Seasonal dragon in the season of a provided date.
		 *
		 * @private
		 * @memberof Image.
		 *
		 * @param {moment} [date=moment()] - The date that is used to get the season.
		 * @return {String} Dragonvale Wiki picture URL of Seasonal dragon in the season of the passed date.
		 *
		 * @see {@link http://momentjs.com/docs moment.js documentation}
		 */
		Seasonal: function(date) {
			return vm.getImg(getSeason(date) + 'SeasonalDragonAdult.png');
		}
	};

	/**
	 * @borrows getWeirdDragonImg.Snowflake as getWeirdDragonImg.Monolith
	 */
	getWeirdDragonImg.Monolith = getWeirdDragonImg.Snowflake;

	/**
	 * This function derives the egg name from the
	 * one of the passed dragon. It is useful due
	 * to Seasonal, Snowflake and Monolith dragons
	 * having different names for dragon and egg images.
	 *
	 * @summary Returns the egg name of the passed dragon.
	 *
	 * @private
	 * @memberof Image.
	 *
	 * @param {string} name - The name of the dragon.
	 * @return {string} The egg name of the passed dragon.
	 */
	var getEggName = function(name) {
		var eggName = name.match(/(Seasonal|Snowflake|Monolith)/);
		return eggName ? eggName[0] : name;
	};

	/**
	 * @summary Returns the Dragonvale Wiki URL of
	 * the passed file name.
	 *
	 * @memberof Image.
	 *
	 * @param {string} fileName - Input filename.
	 * @return {stirng} URL of fileName on Dragonvale WIki.
	 */
	vm.getImg = function(fileName) {
		fileName = fileName.replace(/ /g, '');
		var checkSum = md5.createHash(fileName);
		return [baseURL, checkSum[0], checkSum.substr(0, 2),
				fileName].join('/');
	};

	/**
	 * @summary Returns the Dragonvale Wiki image URL
	 * of the egg having the passed name.
	 *
	 * @memberof Image.
	 *
	 * @param {string} name - The name of the egg.
	 * @return {stirng} URL of the egg image on Dragonvale WIki.
	 */
	vm.getEggImg = function(name) {
		return vm.getImg(getEggName(name) + 'DragonEgg.png');
	};

	/**
	 * @summary Returns the Dragonvale Wiki image URL
	 * of the adult dragon having the passed name.
	 *
	 * @memberof Image.
	 *
	 * @param {string} name - The name of the dragon.
	 * @return {stirng} URL of the adult dragon image on Dragonvale WIki.
	 */
	vm.getDragonImg = function(name) {
		var eggName = getEggName(name);
		return getWeirdDragonImg[eggName]
			? getWeirdDragonImg[eggName](name, eggName)
			: vm.getImg(name + 'DragonAdult.png');
	};

	/**
	 * @summary Returns the Dragonvale Wiki image URL
	 * of the elemental flag having the passed element name.
	 *
	 * @memberof Image.
	 *
	 * @param {string} name - The name of the element.
	 * @return {stirng} URL of the elemental flag image on Dragonvale WIki.
	 */
	vm.getElemFlagImg = function(elem) {
		return vm.getImg(elem + '_Flag.png');
	};
}])
/**
 * @fileoverview
 *
 * This component is made up of the pictures
 * of a dragon in its adult stage and its egg,
 * followed by dragons name and hatching time,
 * and finally by the elemental flag pictures
 * of its elements.
 *
 * The input is a Dragon instance, whose data
 * will be rendered.
 *
 * The output is a callback, onClick, fired on
 * the namesake event: an 'id' argument is
 * passed, holding the represented dragon id.
 *
 * @see Dragon
 */


.component('dragonBox', {
	controllerAs: 'model',
	templateUrl: '../html/dragon-box.html',

	bindings: {
		dragon: '<',

		onClick: '&'
	},

	controller: ['Image', function(image) {
		var vm = this;

		vm.eggImgURL = image.getEggImg(vm.dragon.name);
		vm.dragonImgURL = image.getDragonImg(vm.dragon.name);
		vm.elemsImgsURLs = [];
		angular.forEach(vm.dragon.elems, function(elem) {
			vm.elemsImgsURLs.push(image.getElemFlagImg(elem));
		});
	}]
})
/**
 * @fileoverview
 *
 * This component is made up of a picture of
 * an element and its English name below.
 *
 * The input is an English element name, given
 * as a plain string. There are no outputs.
 */


.component('elemBox', {
	controllerAs: 'model',
	templateUrl: '../html/elem-box.html',

	bindings: {
		name: '<'
	},

	controller: ['Image', function(image) {
		this.imgURL = image.getElemFlagImg(this.name);
	}]
});

})(window, document, angular);
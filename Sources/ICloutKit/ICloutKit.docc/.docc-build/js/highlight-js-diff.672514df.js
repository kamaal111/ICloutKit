/*!
 * This source file is part of the Swift.org open source project
 * 
 * Copyright (c) 2021 Apple Inc. and the Swift project authors
 * Licensed under Apache License v2.0 with Runtime Library Exception
 * 
 * See https://swift.org/LICENSE.txt for license information
 * See https://swift.org/CONTRIBUTORS.txt for Swift project authors
 */
(window["webpackJsonp"]=window["webpackJsonp"]||[]).push([["highlight-js-diff"],{"48b8":function(n,e){function t(n){return n?"string"===typeof n?n:n.source:null}function i(n){const e=n[n.length-1];return"object"===typeof e&&e.constructor===Object?(n.splice(n.length-1,1),e):{}}function a(...n){const e=i(n),a="("+(e.capture?"":"?:")+n.map(n=>t(n)).join("|")+")";return a}function c(n){return{name:"Diff",aliases:["patch"],contains:[{className:"meta",relevance:10,match:a(/^@@ +-\d+,\d+ +\+\d+,\d+ +@@/,/^\*\*\* +\d+,\d+ +\*\*\*\*$/,/^--- +\d+,\d+ +----$/)},{className:"comment",variants:[{begin:a(/Index: /,/^index/,/={3,}/,/^-{3}/,/^\*{3} /,/^\+{3}/,/^diff --git/),end:/$/},{match:/^\*{15}$/}]},{className:"addition",begin:/^\+/,end:/$/},{className:"deletion",begin:/^-/,end:/$/},{className:"addition",begin:/^!/,end:/$/}]}}n.exports=c}}]);
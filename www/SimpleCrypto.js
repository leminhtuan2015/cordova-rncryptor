// var crypto = cordova.require("com.disusered.simplecrypto.SimpleCrypto");

var exec = require('cordova/exec');

var SimpleCrypto = function() {};

SimpleCrypto.prototype.encrypt = function(key, originFilePath, encryptedFilePath, success, error) {
  exec(success, error, "SimpleCrypto", "encrypt", [key, originFilePath, encryptedFilePath]);
}

SimpleCrypto.prototype.decrypt = function(key, encryptedFilePath, originFilePath, success, error) {
  exec(success, error, "SimpleCrypto", "decrypt", [key, encryptedFilePath, originFilePath]);
}

SimpleCrypto.prototype.removeFiles = function(originFilePath, contain, success, error) {
    exec(success, error, "SimpleCrypto", "removeFiles", [originFilePath, contain]);
}

var simpleCrypto = new SimpleCrypto();

module.exports = simpleCrypto;

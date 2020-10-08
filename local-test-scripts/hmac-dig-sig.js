const moment = require('moment');
let timestamp = moment().utc().format('ddd, DD MMM YYYY HH:mm:ss') + ' GMT';

let signing_string = "date: " + timestamp + "\n" 
    + pm.request.method + " " 
    + pm.request.url.getPath() + " "
    + "HTTP/1.1";

const secret_key = /* INSERT SECRET HERE */;

const hmac_encoded_str = CryptoJS.HmacSHA256(signing_string, secret_key);

const signature = hmac_encoded_str.toString(CryptoJS.enc.Base64);

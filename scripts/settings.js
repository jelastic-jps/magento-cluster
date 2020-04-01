import com.hivext.api.Response;
import org.yaml.snakeyaml.Yaml;
import com.hivext.api.core.utils.Transport;

var cdnAppid = "c05ffa5b45628a2a0c95467ebca8a0b4";
var lsAppid = "9e6afcf310004ac84060f90ff41a5aba";
var group = jelastic.billing.account.GetAccount(appid, session);
var isCDN = jelastic.dev.apps.GetApp(cdnAppid);
var isLS = jelastic.dev.apps.GetApp(lsAppid);

var sameNodes = "environment.maxsamenodescount";
var maxNodes = "environment.maxnodescount";
var minEnvNodes = 7, minEnvLayerNodes = 3, quotaName, quotaValue,  quotaText = "", 
    quota = jelastic.billing.account.GetQuotas(maxNodes + ";" + sameNodes).array || [];
    
for (var i = 0, n = quota.length; i < n; i++) {
    quotaName = quota[i].quota.name;
    quotaValue = quota[i].value;

    if (quotaName == maxNodes && quotaValue < minEnvNodes) {
        quotaText = "Quota limits: " + quotaName + " = " + quotaValue + ". Min value is " + minEnvNodes + ".  Please upgrade your account.";
        continue;
    }

    if (quotaName == sameNodes && quotaValue < minEnvLayerNodes) {
        quotaText = "Quota limits: " + quotaName + " = " + quotaValue + ". Min value is " + minEnvLayerNodes + ".  Please upgrade your account.";
        continue;
    }
}

var settings = jps.settings;
var fields = {};
for (var i = 0, field; field = jps.settings.fields[i]; i++)
  fields[field.name] = field;

var resp = jelastic.billing.account.GetQuotas('environment.externalip.enabled');
if (resp.result == 0 && resp.array[0].value) {
  fields["le-addon"].hidden = true;
  fields["le-addon"].disabled = true;
}


if (quotaText) {
    settings.fields.push(
        {"type": "displayfield", "cls": "warning", "height": 30, "hideLabel": true, "markup": quotaText},
        {"type": "compositefield","height": 0,"hideLabel": true,"width": 0,"items": [{"height": 0,"type": "string","required": true}]}
    );
}

return {
    result: 0,
    settings: settings
};

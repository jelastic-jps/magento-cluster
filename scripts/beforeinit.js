import com.hivext.api.Response;
import org.yaml.snakeyaml.Yaml;
import com.hivext.api.core.utils.Transport;

var cdnAppid = "c05ffa5b45628a2a0c95467ebca8a0b4";
var lsAppid = "9e6afcf310004ac84060f90ff41a5aba";
var group = jelastic.billing.account.GetAccount(appid, session);
var isCDN = jelastic.dev.apps.GetApp(cdnAppid);
var isLS = jelastic.dev.apps.GetApp(lsAppid);

//checking quotas
var perEnv = "environment.maxnodescount",
      maxEnvs = "environment.maxcount",
      perNodeGroup = "environment.maxsamenodescount",
      maxCloudletsPerRec = "environment.maxcloudletsperrec",
      extIP = "environment.externalip.enabled",
      extIPperEnv = "environment.externalip.maxcount",
      extIPperNode = "environment.externalip.maxcount.per.node",
      isDocker = "environment.docker.enabled";
var   nodesPerEnvMin = 7,
      nodesPerGroupMin = 2,
      maxCloudlets = 32,
      markup = "", cur = null, text = "used", prod = true, litespeed = true;

var settings = jps.settings;
var fields = {};
for (var i = 0, field; field = jps.settings.fields[i]; i++)
  fields[field.name] = field;

var quotas = jelastic.billing.account.GetQuotas(perEnv + ";"+maxEnvs+";" + perNodeGroup + ";" + maxCloudletsPerRec + ";" + extIP + ";" + extIPperEnv + ";" + extIPperNode + ";" + isDocker).array;
var group = jelastic.billing.account.GetAccount(appid, session);
for (var i = 0; i < quotas.length; i++){
    var q = quotas[i], n = toNative(q.quota.name);

    if (n == maxCloudletsPerRec && maxCloudlets > q.value){
        err(q, "required", maxCloudlets, true);
        prod  = false; 
    }
    
    if (n == perEnv && nodesPerEnvMin > q.value){
        if (!markup) err(q, "required", nodesPerEnvMin, true);
        prod = false;
    }

    if (n == perNodeGroup && nodesPerGroupMin > q.value){
        if (!markup) err(q, "required", nodesPerGroupMin, true);
        prod = false;
    }

    if (n == isDocker &&  !q.value){
        if (!markup) err(q, "required", 1, true);
        prod  = false; 
    }
      
    if (n == extIP && !q.value){
        if (!markup) err(q, "required", 1, true);
        fields["le_addon"].disabled = true;
        fields["le_addon"].value = false;
        prod = false;
    }

    if (n == extIPperEnv && 1 > q.value){
        if (!markup) err(q, "required", 1, true);
        fields["le_addon"].disabled = true;
        fields["le_addon"].value = false;
        prod = false;
    }

    if (n == extIPperNode && 1 > q.value){
        if (!markup) err(q, "required", 1, true);
        fields["le_addon"].disabled = true;
        fields["le_addon"].value = false;
        prod = false;
    }
}    
    
if (isLS.result == 0 || isLS.result == Response.PERMISSION_DENIED) {
  fields["ls_addon"].disabled = false;
  fields["ls_addon"].value = true;         
} else {
  prod = false;
  litespeed = false;
  fields["ls_addon"].disabled = true;
  fields["ls_addon"].value = false;
}
    
if (isCDN.result == 0 || isCDN.result == Response.PERMISSION_DENIED) {
  fields["cdn_addon"].hidden = false;
  fields["cdn_addon"].value = true;
} else {
  fields["cdn_addon"].hidden = true;
  fields["cdn_addon"].value = false;
}

if (!prod || group.groupType == 'trial') {
  fields["bl_count"].markup = "Cluster is not available. " + markup + "Please upgrade your account.";
  if (!litespeed)
    fields["bl_count"].markup = "LiteSpeed software stack templates are not supported at the moment.";
  if (group.groupType == 'trial')
    fields["bl_count"].markup = "Magento cluster is not available for " + group.groupType + ". Please upgrade your account.";
  fields["bl_count"].cls = "warning";
  fields["bl_count"].hidden = false;
  fields["bl_count"].height = 30;
  
  settings.fields.push(
    {"type": "compositefield","height": 0,"hideLabel": true,"width": 0,"items": [{"height": 0,"type": "string","required": true}]}
  );
}

return {
    result: 0,
    settings: settings
};

function err(e, text, cur, override){
  var m = (e.quota.description || e.quota.name) + " - " + e.value + ", " + text + " - " + cur + ". ";
  if (override) markup = m; else markup += m;
}

/* Pushing data to SQL for Batch Processing Analysis */
      select
        e.version
        ,e.secret
        ,e.type
        ,getarrayelement(e.data.apfloors,0) as apFloors
        ,GetArrayElement(e.data.apTags, 1) as apTags
        ,e.data.apMac
        ,observations.arrayvalue.manufacturer
        ,observations.arrayvalue.location.lng
        ,observations.arrayvalue.location.lat
        ,getarrayelement(observations.arrayvalue.location.x,0) as x
        ,getarrayelement(observations.arrayvalue.location.y,0) as y
        ,observations.arrayvalue.location.unc
        ,observations.arrayvalue.seentime
        ,observations.arrayvalue.ssid
        ,observations.arrayvalue.os
        ,observations.arrayvalue.clientMac
        ,observations.arrayvalue.seenEpoch
        ,observations.arrayvalue.rssi 
      into [sqloutput]
      from [inputevent] as e
        cross apply getarrayElements(e.data.observations) as observations

/* Pushing data to Power BI Real-Time Processing */
        select
        e.version
        ,e.secret
        ,e.type
        ,getarrayelement(e.data.apfloors,0) as apFloors
        ,GetArrayElement(e.data.apTags, 1) as apTags
        ,e.data.apMac
        ,observations.arrayvalue.manufacturer
        ,observations.arrayvalue.location.lng
        ,observations.arrayvalue.location.lat
        ,getarrayelement(observations.arrayvalue.location.x,0) as x
        ,getarrayelement(observations.arrayvalue.location.y,0) as y
        ,observations.arrayvalue.location.unc
        ,observations.arrayvalue.seentime
        ,observations.arrayvalue.ssid
        ,observations.arrayvalue.os
        ,observations.arrayvalue.clientMac
        ,observations.arrayvalue.seenEpoch
        ,observations.arrayvalue.rssi
      into [powerbi]
      from [inputevent] as e
        cross apply getarrayElements(e.data.observations) as observations
/* Pushing data to Blob Storage for Raw events to be replayed in case of any errors */
SELECT * INTO [bloboutput] FROM [inputevent]
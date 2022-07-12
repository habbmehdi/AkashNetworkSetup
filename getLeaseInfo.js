function getValue(json,key,value){ 

    var parsedJSON = JSON.parse(json)

    var ports = parsedJSON.forwarded_ports.web

    if(key == 'port'){ 
        for( const forwardedports of ports){ 
            if (forwardedports.port == value){
                return forwardedports.externalPort
            }
        }
    }else if (key == 'host'){ 
        return ports[0].host
    }
}

console.log(getValue(process.argv[2],process.argv[3],process.argv[4]))
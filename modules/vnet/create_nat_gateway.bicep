param deploymentParams object
param natGwParams object
param tags object = resourceGroup().tags

resource r_natGwPublicIp 'Microsoft.Network/publicIpAddresses@2022-05-01' = {
  name: '${natGwParams.natGwNamePrefix}_NatGw_${deploymentParams.global_uniqueness}_publicIp'
  location: deploymentParams.location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    deleteOption:'Delete'
  }  
  // zones: [
  //   natGwParams.zoneNo
  // ]
}

resource r_publicIPPrefix 'Microsoft.Network/publicIPPrefixes@2021-02-01' = {
  name: '${natGwParams.natGwNamePrefix}_NatGw_${deploymentParams.global_uniqueness}_publicIPPrefix'
  location: deploymentParams.location
  sku: {
    name: 'Standard'
  }
  properties: {
    prefixLength: 29
    publicIPAddressVersion: 'IPv4'
  }
}

resource r_nic_01 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: '${vmName}-Nic-01'
  location: deploymentParams.location
  tags: tags
  properties: {
    ipConfigurations: [
      { 
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, vmParams.vmSubnetName)
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: r_publicIp.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: r_webSg.id
    }
  }
}



resource r_natGateway 'Microsoft.Network/natGateways@2021-02-01' = {
  name: '${natGwParams.natGwNamePrefix}_NatGw_${deploymentParams.global_uniqueness}'
  location: deploymentParams.location
  tags: tags
  sku: {
    name: '${natGwParams.sku}'
  }

  properties: {
    idleTimeoutInMinutes: 4
    publicIpAddresses: [
      {
        id: r_natGwPublicIp.id
      }
    ]
  }
  // zones: [
  //   natGwParams.zoneNo
  // ]
}

output natGwId string = r_natGateway.id

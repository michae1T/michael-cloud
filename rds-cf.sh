#!/bin/bash

cat << EOF
{
  "AWSTemplateFormatVersion" : "2010-09-09",

  "Description" : "PostgreSQL RDS Template ",

  "Parameters" :
EOF

cat $1

cat << EOF

  ,

  "Resources" : {

    "DBEC2SecurityGroup": {
      "Type": "AWS::EC2::SecurityGroup",
      "Properties" : {
        "GroupDescription" : "Frontend Access",
        "VpcId"            : { "Ref" : "VpcId" },
        "SecurityGroupIngress" : [{
          "IpProtocol" : "tcp",
          "FromPort"   : 5432,
          "ToPort"     : 5432,
          "CidrIp"     : { "Ref" : "CidrIp" }
        }]
      }
    },

    "DBParamGroup": {
        "Type": "AWS::RDS::DBParameterGroup",
        "Properties": {
            "Family": "postgres9.5",
             "Description": "DB Parameter Group",
             "Parameters": {
                "shared_preload_libraries": "pg_stat_statements"
            }
        }
    },

    "DBSubnetGroup" : {
      "Type" : "AWS::RDS::DBSubnetGroup",
      "Properties" : {
         "DBSubnetGroupDescription" : "DB Private Subnet",
         "SubnetIds" : { "Ref" : "SubnetIds" }
      }
    },

    "DB" : {
      "Type" : "AWS::RDS::DBInstance",
      "Properties" : {
        "DBName" : { "Ref" : "DBName" },
        "AllocatedStorage" : { "Ref" : "DBAllocatedStorage" },
        "DBInstanceClass" : { "Ref" : "DBClass" },
        "Engine" : "postgres",
        "MasterUsername" : { "Ref" : "DBUsername" },
        "MasterUserPassword" : { "Ref" : "DBPassword" },
        "DBSubnetGroupName" : { "Ref" : "DBSubnetGroup" },
        "DBParameterGroupName" : {"Ref" : "DBParamGroup" },
        "VPCSecurityGroups" : [ { "Fn::GetAtt" : [ "DBEC2SecurityGroup", "GroupId" ] } ]
      }
    }
  }
}
EOF


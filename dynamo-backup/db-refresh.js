var copy = require('copy-dynamodb-table').copy
var DynamoDB = require('aws-sdk/clients/dynamodb');

// Check for parameters being set
if(process.env.SOURCE_AWS_KEY && process.env.SOURCE_AWS_KEY && process.env.DESTINATION_AWS_KEY && process.env.DESTINATION_SECRET_KEY) { 
  console.log('Environment variables found'); 
}
else { 
  console.log('Environment variables not set!'); 
  return process.exit(911);
}


// Deleting the existing dynamodb table to make way for a new one
var destinationdynamodb = new DynamoDB({
    apiVersion: '2012-08-10',
    region: process.env.REGION, 
    credentials: {
      accessKeyId: process.env.DESTINATION_AWS_KEY,
      secretAccessKey: process.env.DESTINATION_SECRET_KEY
    }
  }
);

var params = {
  TableName: process.env.TABLE_NAME
};

console.log("Deleting existing table");
destinationdynamodb.deleteTable(params, function(err, data) {
   if (err) console.log(err, err.stack); // an error occurred
   else     console.log(data);
});

// Wait for table to delete
destinationdynamodb.waitFor('tableNotExists', params, function(err, data) {
  if (err) console.log(err, err.stack); // an error occurred
  else     copyTable();           // successful response results iin copying the table
});

// Copy table cross account
function copyTable() {
  console.log("Copying table");
  // Credentials object for table you are copying FROM
  var sourceAWSConfig = {
    accessKeyId: process.env.SOURCE_AWS_KEY,
    secretAccessKey: process.env.SOURCE_SECRET_KEY,
    region: process.env.REGION
  }

  // Credentials object for table you are copying TO
  var destinationAWSConfig = {
    accessKeyId: process.env.DESTINATION_AWS_KEY,
    secretAccessKey: process.env.DESTINATION_SECRET_KEY,
    region: process.env.REGION // support cross zone copying
  }

  // Copies table over from source to dest.
  copy({
    source: {
      tableName: process.env.TABLE_NAME, // required
      config: sourceAWSConfig // optional , leave blank to use globalAWSConfig
    },
    destination: {
      tableName: process.env.TABLE_NAME, // required
      config: destinationAWSConfig // optional , leave blank to use globalAWSConfig      
    },
    log: true,// default false
    create : true // create destination table if not exist
    },
    function (err, result) {
      if (err) {
        console.log(err)
      }
      console.log(result)
    }
  );
}
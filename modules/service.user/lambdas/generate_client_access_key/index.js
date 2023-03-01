"use strict";

const crypto = require("crypto");
const { verifyToken, hashWithSalt, dbQuery } = require("./utils");

const insertAccessKey = async (userId, accessKey, hash) => {
  return dbQuery(
    `INSERT INTO client_access_keys (user_id, access_key, access_key_hash) VALUES (:userId, :accessKey, :hash)`,
    { userId, accessKey, hash }
  );
};

exports.handler = async (event, context, callback) => {
  try {
    const auth = event?.headers?.Authorization.split(" ");
    if (auth?.[0].toLowerCase() !== "bearer") {
      throw new Error("Missing bearer token");
    }

    const bearerToken = auth[1];

    const decodedToken = await verifyToken(bearerToken);
    const { user_id } = decodedToken;

    const accessKey = crypto.randomBytes(10).toString("hex");
    const secretAccessKey = crypto.randomBytes(20).toString("hex");

    const { hash } = await hashWithSalt(
      accessKey.toUpperCase(),
      secretAccessKey
    );

    await insertAccessKey(user_id, accessKey.toUpperCase(), hash);

    callback(null, {
      statusCode: 200,
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: JSON.stringify({
        message: `Here is your access key and secret key. It will be needed to interact with your datastores. Do NOT share this with anyone. If a key is compromised or lost, its your responsibility to delete it, you will need to regenerate a new access key and secret key`,
        access_key: accessKey.toUpperCase(),
        secret_access_key: secretAccessKey,
      }),
    });
  } catch (error) {
    callback(null, {
      statusCode: 400,
      headers: { "Content-Type": "application/json; charset=utf-8" },
      body: JSON.stringify({
        message: error.message,
      }),
    });
  }
};

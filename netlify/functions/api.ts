import serverless from 'serverless-http';
import { createApp } from '../../src/app';
import { connectDb } from '../../src/config/db';

let dbConnected = false;

const app = createApp();

const handler = serverless(app);

export const handlerFunction = async (event: any, context: any) => {
  if (!dbConnected) {
    await connectDb();
    dbConnected = true;
  }
  return handler(event, context);
};

exports.handler = handlerFunction;

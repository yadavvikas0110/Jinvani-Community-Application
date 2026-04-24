import serverless from 'serverless-http';
import { createApp } from '../../src/app';
import { connectDb } from '../../src/config/db';

let dbConnected = false;

const app = createApp();

const appHandler = serverless(app);

export const handler = async (event: any, context: any) => {
  if (!dbConnected) {
    await connectDb();
    dbConnected = true;
  }
  return appHandler(event, context);
};

# Ellion API

[![ci](https://github.com/deolivtiago/ellion-api/actions/workflows/ci.yml/badge.svg)](https://github.com/deolivtiago/ellion-api/actions/workflows/ci.yml)
[![coverage](https://coveralls.io/repos/github/deolivtiago/ellion-api/badge.svg)](https://coveralls.io/github/deolivtiago/ellion-api)

## Setup

### Getting started

- Rename the `.env.example` file to `.env` and set the environment variables values

### Running the app

Requirements:

- Install `Node.js 20+`
- Install `Yarn 1.22+`
- Install `Postgres 15+`

To start your server:

- Install dependencies with `yarn install`
- Run database migrations with `yarn prisma db push`
- Start your server with `yarn run start` or in watch mode with `yarn run start:dev`

Now you can visit [`localhost:3000`](http://localhost:3000) from your browser.

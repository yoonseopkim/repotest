FROM node:20-alpine AS builder

WORKDIR /gitfolio_front

COPY package*.json /gitfolio_front

RUN npm install -g next
RUN npm ci

COPY . .

RUN npm run build

####################################

FROM node:20-alpine AS runner

WORKDIR /gitfolio_front

ENV NODE_ENV production
ENV PORT 3000

EXPOSE 3000

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

RUN chown -R nextjs:nodejs /gitfolio_front

USER nextjs

COPY --from=builder /gitfolio_front .

CMD ["npm", "run", "start"]
const gatewayId = "234234";
const mapping: Record<string, string> = redis.get(
  `gateway:${gatewayId}:mapping`,
);
setTimeout(() => {}, 2000);

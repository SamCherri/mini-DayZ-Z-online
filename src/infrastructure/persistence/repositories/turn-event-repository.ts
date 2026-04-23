import { getPrismaClient } from "../prisma-client";

export async function saveTurnEvent(input: {
  roomId: string;
  eventType: string;
  payload: string;
  turnNumber: number;
}) {
  const prisma = getPrismaClient();

  return prisma.turnEvent.create({
    data: {
      roomId: input.roomId,
      eventType: input.eventType,
      payload: input.payload,
      turnNumber: input.turnNumber,
    },
  });
}

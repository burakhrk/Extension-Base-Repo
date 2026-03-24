import { APP_ID } from './constants'

export type AnalyticsPayload = Record<string, unknown>

export async function track(eventName: string, properties: AnalyticsPayload = {}) {
  const payload = {
    eventName,
    properties: {
      appId: APP_ID,
      ...properties,
    },
  }

  console.log('analytics', payload)
}

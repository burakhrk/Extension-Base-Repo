export type SocialState = {
  app_id: string
  own_profile: Record<string, unknown> | null
  preferences: Record<string, unknown>
  incoming_requests: Array<Record<string, unknown>>
  outgoing_requests: Array<Record<string, unknown>>
  accepted_friends: Array<Record<string, unknown>>
  active_sessions: Array<Record<string, unknown>>
}

import { APP_ID } from './constants'
import { supabase } from './supabase'
import type { SocialState } from '../types/social'

export const socialClient = {
  async bootstrap() {
    const { data, error } = await supabase.rpc('get_social_state', {
      p_app_id: APP_ID,
    })
    if (error) throw error
    return data as SocialState
  },

  async setPreferences(input: {
    extensionEnabled?: boolean
    appearOnline?: boolean
    allowSurprise?: boolean
  }) {
    return supabase.rpc('set_app_preferences', {
      p_app_id: APP_ID,
      p_extension_enabled: input.extensionEnabled ?? null,
      p_appear_online: input.appearOnline ?? null,
      p_allow_surprise: input.allowSurprise ?? null,
    })
  },

  async sendFriendRequest(recipientId: string) {
    return supabase.rpc('send_friend_request', {
      p_app_id: APP_ID,
      p_recipient_id: recipientId,
    })
  },

  async acceptFriendRequest(requestId: string) {
    return supabase.rpc('accept_friend_request', {
      p_request_id: requestId,
    })
  },

  async rejectFriendRequest(requestId: string) {
    return supabase.rpc('reject_friend_request', {
      p_request_id: requestId,
    })
  },

  async startSession(targetUserId: string, mode: 'send' | 'live') {
    return supabase.rpc('start_session', {
      p_app_id: APP_ID,
      p_target_user_id: targetUserId,
      p_mode: mode,
    })
  },

  async endSession(sessionId: string) {
    return supabase.rpc('end_session', {
      p_session_id: sessionId,
    })
  },
}

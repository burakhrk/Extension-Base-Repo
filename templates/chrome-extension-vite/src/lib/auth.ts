import { supabase } from './supabase'

export async function signInWithGoogle() {
  const redirectTo = chrome.identity.getRedirectURL()
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo,
      skipBrowserRedirect: true,
      queryParams: {
        access_type: 'offline',
        prompt: 'consent',
      },
    },
  })

  if (error) throw error
  if (!data?.url) throw new Error('No Google sign-in URL returned.')

  const callbackUrl = await chrome.identity.launchWebAuthFlow({
    url: data.url,
    interactive: true,
  })

  if (!callbackUrl) throw new Error('Google sign-in was cancelled.')

  const callback = new URL(callbackUrl)
  const code = callback.searchParams.get('code')
  const oauthError = callback.searchParams.get('error_description') || callback.searchParams.get('error')

  if (oauthError) throw new Error(oauthError)
  if (!code) throw new Error('No auth code returned from Google sign-in.')

  const { error: exchangeError } = await supabase.auth.exchangeCodeForSession(code)
  if (exchangeError) throw exchangeError

  const { data: userData } = await supabase.auth.getUser()
  return userData.user
}

export async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) throw error
}

export async function getCurrentUser() {
  const { data, error } = await supabase.auth.getUser()
  if (error?.name === 'AuthSessionMissingError') {
    const { data: sessionData } = await supabase.auth.getSession()
    return sessionData.session?.user ?? null
  }
  if (error) throw error
  return data.user ?? null
}

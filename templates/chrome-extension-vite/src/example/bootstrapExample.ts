import { getCurrentUser, signInWithGoogle } from '../lib/auth'
import { socialClient } from '../lib/socialClient'
import { track } from '../lib/analytics'

export async function bootstrapExtensionState() {
  let user = await getCurrentUser()

  if (!user) {
    return {
      signedIn: false,
      user: null,
      socialState: null,
    }
  }

  const socialState = await socialClient.bootstrap()
  await track('Loaded Social State', { screen: 'bootstrap', result: 'success' })

  return {
    signedIn: true,
    user,
    socialState,
  }
}

export async function signInAndBootstrap() {
  const user = await signInWithGoogle()
  await track('Signed In', { screen: 'auth', result: 'success' })

  const socialState = await socialClient.bootstrap()
  await track('Loaded Social State', { screen: 'bootstrap', result: 'success' })

  return { user, socialState }
}

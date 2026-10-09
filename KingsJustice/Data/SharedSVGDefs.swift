// GENERATED from the original HTML <defs>. Gradients, filters and clip paths shared by every arena and the fighter rig.
import Foundation

enum SharedSVGDefs {
    static let markup: String = ##"""

  <clipPath id="vp"><rect width="1600" height="900"/></clipPath>
  <clipPath id="shc"><path d="M0,-60L32,-45L30,12Q22,50 0,72Q-22,50-30,12L-32,-45Z"/></clipPath>

  <!-- gradients -->
  <linearGradient id="wall" x2="0" y2="1"><stop offset="0" stop-color="#0d0b0a"/><stop offset=".55" stop-color="#241c15"/><stop offset="1" stop-color="#0a0807"/></linearGradient>
  <linearGradient id="sky" x2="0" y2="1"><stop offset="0" stop-color="#07080b"/><stop offset=".6" stop-color="#1a1512"/><stop offset="1" stop-color="#0a0807"/></linearGradient>
  <linearGradient id="kS"><stop offset="0" stop-color="#a7b4c2"/><stop offset=".22" stop-color="#5d6877"/><stop offset=".55" stop-color="#232930"/><stop offset="1" stop-color="#434c59"/></linearGradient>
  <linearGradient id="gS"><stop offset="0" stop-color="#8a7048"/><stop offset=".2" stop-color="#352b2e"/><stop offset=".6" stop-color="#0a090a"/><stop offset="1" stop-color="#2a2123"/></linearGradient>
  <linearGradient id="blade" x2="0" y2="1"><stop offset="0" stop-color="#f6f9fb"/><stop offset=".5" stop-color="#848e98"/><stop offset="1" stop-color="#2c3238"/></linearGradient>
  <linearGradient id="bladeDark" x2="0" y2="1"><stop offset="0" stop-color="#d9dde0"/><stop offset=".5" stop-color="#6c747c"/><stop offset="1" stop-color="#1f2428"/></linearGradient>
  <linearGradient id="gold" x2="0" y2="1"><stop offset="0" stop-color="#f6da86"/><stop offset=".5" stop-color="#97742c"/><stop offset="1" stop-color="#3a2a0e"/></linearGradient>
  <linearGradient id="cloak" x2="0" y2="1"><stop offset="0" stop-color="#4a0b10"/><stop offset="1" stop-color="#0a0304"/></linearGradient>
  <linearGradient id="cloakK" x2="0" y2="1"><stop offset="0" stop-color="#2a323c"/><stop offset="1" stop-color="#07090c"/></linearGradient>
  <linearGradient id="shaftG" x2="0" y2="1"><stop offset="0" stop-color="#b8c8ea" stop-opacity=".2"/><stop offset=".7" stop-color="#b8c8ea" stop-opacity=".05"/><stop offset="1" stop-color="#b8c8ea" stop-opacity="0"/></linearGradient>
  <linearGradient id="mudG" x2="0" y2="1"><stop offset="0" stop-color="#3d3023"/><stop offset=".35" stop-color="#261c14"/><stop offset="1" stop-color="#0c0806"/></linearGradient>
  <linearGradient id="flame" x2="0" y2="1"><stop offset="0" stop-color="#fff4b8"/><stop offset=".45" stop-color="#ff9a1f"/><stop offset="1" stop-color="#c22a00" stop-opacity=".15"/></linearGradient>
  <linearGradient id="mist" x2="0" y2="1"><stop offset="0" stop-color="#a39884" stop-opacity="0"/><stop offset=".5" stop-color="#a39884" stop-opacity=".17"/><stop offset="1" stop-color="#a39884" stop-opacity="0"/></linearGradient>
  <linearGradient id="god" x2="1"><stop offset="0" stop-color="#ffcf8a" stop-opacity="0"/><stop offset=".5" stop-color="#ffcf8a" stop-opacity=".09"/><stop offset="1" stop-color="#ffcf8a" stop-opacity="0"/></linearGradient>
  <radialGradient id="tg"><stop offset="0" stop-color="#ffa347" stop-opacity=".62"/><stop offset=".5" stop-color="#b0480f" stop-opacity=".22"/><stop offset="1" stop-color="#b0480f" stop-opacity="0"/></radialGradient>
  <radialGradient id="blood"><stop offset="0" stop-color="#8a0808"/><stop offset=".6" stop-color="#4a0000"/><stop offset="1" stop-color="#1a0000" stop-opacity="0"/></radialGradient>
  <radialGradient id="pool"><stop offset="0" stop-color="#6a0707"/><stop offset=".55" stop-color="#360202"/><stop offset="1" stop-color="#150000" stop-opacity="0"/></radialGradient>
  <radialGradient id="poolShine"><stop offset="0" stop-color="#ff7a5a" stop-opacity=".35"/><stop offset="1" stop-color="#ff7a5a" stop-opacity="0"/></radialGradient>
  <radialGradient id="spk"><stop offset="0" stop-color="#fff" stop-opacity=".95"/><stop offset=".3" stop-color="#ffb347" stop-opacity=".55"/><stop offset="1" stop-color="#ff7a00" stop-opacity="0"/></radialGradient>
  <radialGradient id="lL" gradientUnits="userSpaceOnUse" cx="170" cy="400" r="900"><stop offset="0" stop-color="#ff8a2a" stop-opacity=".42"/><stop offset="1" stop-color="#ff8a2a" stop-opacity="0"/></radialGradient>
  <radialGradient id="lR" gradientUnits="userSpaceOnUse" cx="1430" cy="400" r="900"><stop offset="0" stop-color="#ff8a2a" stop-opacity=".42"/><stop offset="1" stop-color="#ff8a2a" stop-opacity="0"/></radialGradient>
  <radialGradient id="vig" cx=".5" cy=".5" r=".78"><stop offset=".42" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity=".94"/></radialGradient>
  <radialGradient id="hurt" cx=".5" cy=".5" r=".7"><stop offset=".3" stop-color="#5a0000" stop-opacity="0"/><stop offset="1" stop-color="#8a0000" stop-opacity=".85"/></radialGradient>

  <!-- filters (applied to STATIC or low-count layers only, for stable 60fps) -->
  <filter id="metal" x="-15%" y="-15%" width="130%" height="130%"><feTurbulence type="fractalNoise" baseFrequency=".006 .45" numOctaves="2" seed="7" result="n"/><feColorMatrix in="n" type="matrix" values="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 1" result="g"/><feComposite in="SourceGraphic" in2="g" operator="arithmetic" k1="0" k2="1" k3=".32" k4="-.14" result="m"/><feComposite in="m" in2="SourceAlpha" operator="in"/></filter>
  <filter id="mud" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency=".012 .05" numOctaves="3" seed="4" result="n"/><feDiffuseLighting in="n" surfaceScale="5" lighting-color="#ffd9a8" result="l"><feDistantLight azimuth="225" elevation="40"/></feDiffuseLighting><feComposite in="l" in2="SourceGraphic" operator="arithmetic" k1="1.7" k2="0" k3="0" k4="0"/></filter>
  <filter id="st" x="0" y="0" width="100%" height="100%"><feTurbulence type="fractalNoise" baseFrequency=".03 .05" numOctaves="3" seed="2" result="n"/><feColorMatrix in="n" type="matrix" values="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 0 1" result="g"/><feComposite in="g" in2="SourceGraphic" operator="arithmetic" k1="2.3" k2="0" k3="0" k4="0"/></filter>
  <filter id="bd" x="-30%" y="-30%" width="160%" height="160%"><feTurbulence type="fractalNoise" baseFrequency=".05" numOctaves="3" seed="3" result="n"/><feDisplacementMap in="SourceGraphic" in2="n" scale="26"/><feGaussianBlur stdDeviation="1.2"/></filter>
  <filter id="pd" x="-30%" y="-60%" width="160%" height="220%"><feTurbulence type="fractalNoise" baseFrequency=".02 .06" numOctaves="3" seed="9" result="n"/><feDisplacementMap in="SourceGraphic" in2="n" scale="60"/><feGaussianBlur stdDeviation="2"/></filter>
  <filter id="ink" x="-5%" y="-30%" width="110%" height="160%"><feTurbulence type="fractalNoise" baseFrequency=".08" numOctaves="2" result="n"/><feDisplacementMap in="SourceGraphic" in2="n" scale="2.5"/><feGaussianBlur stdDeviation=".4"/></filter>
  <filter id="b1" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="1.6"/></filter>
  <filter id="b3" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="3"/></filter>
  <filter id="b4" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="4"/></filter>
  <filter id="b6" x="-5%" y="-20%" width="110%" height="140%"><feGaussianBlur stdDeviation="6"/></filter>
  <filter id="b9" x="-20%" y="-5%" width="140%" height="110%"><feGaussianBlur stdDeviation="9"/></filter>
  <filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="2.2" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
  <path id="arch" d="M-100,420Q-100,290 0,255Q100,290 100,420V760H-100Z"/>

"""##
}

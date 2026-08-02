/* CampusConnect UI/UX Showcase Application Engine */

// Firebase Config Integration for Real SMS Verification
let firebaseConfig = {
  apiKey: "AIzaSyCQVkmOR1jZBw4DZFWYcLVY6nzwAeAb_eM",
  authDomain: "campusconnect-f17e2.firebaseapp.com",
  projectId: "campusconnect-f17e2",
  storageBucket: "campusconnect-f17e2.firebasestorage.app",
  messagingSenderId: "558848717390",
  appId: "1:558848717390:web:e52c0cddf4d5d831ed091f",
  measurementId: "G-WKNX90QZQ2"
};

// Check if developer has connected their custom keys in the app settings panel
const savedFirebaseConfig = localStorage.getItem('cc_firebase_config');
if (savedFirebaseConfig) {
  try {
    firebaseConfig = JSON.parse(savedFirebaseConfig);
  } catch(e) {
    console.warn("Invalid cached Firebase config:", e);
  }
}

let db = null;
if (typeof firebase !== 'undefined') {
  firebase.initializeApp(firebaseConfig);
  db = firebase.firestore();
}

const SVG_ICONS = {
  'school': 'M12 3L1 9l11 6 9-4.91V17h2V9L12 3z M5 13.18v4L12 21l7-3.82v-4L12 17L5 13.18z',
  'home': 'M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z',
  'search': 'M15.5 14h-.79l-.28-.27A6.471 6.471 0 0016 9.5 6.5 6.5 0 109.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z',
  'add': 'M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z',
  'chat_bubble': 'M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z',
  'person': 'M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z',
  'notifications': 'M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z',
  'arrow_back': 'M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z',
  'arrow_back_ios': 'M11.67 3.87L9.9 2.1 0 12l9.9 9.9 1.77-1.77L3.54 12z',
  'menu_book': 'M21 5c-1.11-.9-2.58-1.4-4-1.4-1.5 0-3 .5-4.5 1.4C11 4.1 9.5 3.6 8 3.6c-1.5 0-3 .5-4.5 1.4C2.6 5.6 2 6.7 2 7.9V20c0 1.66 1.34 3 3 3 1.5 0 3-.5 4.5-1.4 1.5.9 3 1.4 4.5 1.4 1.5 0 3-.5 4.5-1.4 1.5.9 3 1.4 4.5 1.4 1.66 0 3-1.34 3-3V7.9c0-1.2-.6-2.3-1.5-2.9zM10 20c-1.5.9-3 1.4-4.5 1.4-1.1 0-2-.9-2-2V8.1c0-.52.26-1 .71-1.24C5.16 6.33 6.58 6 8 6c1.5 0 3 .5 4.5 1.4v10.6c-1.2-.9-2.7-1.4-4.2-1.4-.1 0-.2 0-.3.1zm11-2.1c0 1.1-.9 2-2 2-1.5 0-3-.5-4.5-1.4V7.4c1.5-.9 3-1.4 4.5-1.4 1.42 0 2.84.33 3.79.86.45.24.71.72.71 1.24v10.5z',
  'laptop_mac': 'M20 18c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2H4c-1.1 0-2 .9-2 2v11c0 1.1.9 2 2 2H0v2h24v-2h-4zM4 5h16v11H4V5zm8 14c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1z',
  'directions_bike': 'M15.5 5.5c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zM5 12c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zm0 8.5c-1.93 0-3.5-1.57-3.5-3.5s1.57-3.5 3.5-3.5 3.5 1.57 3.5 3.5-1.57 3.5-3.5 3.5zm7-7.8l-1.9-1.9c-.3-.3-.7-.4-1.1-.4H7v2h1.9l1.4 1.4L7 17.5V22h2v-3.5l-1.8-1.8 2.2 2.2V22h2v-4.5l-2.5-2.5 1.5-3.5 2.2 2.2V17h2v-5l-3.2-3.2zM19 12c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zm0 8.5c-1.93 0-3.5-1.57-3.5-3.5s1.57-3.5 3.5-3.5 3.5 1.57 3.5 3.5-1.57 3.5-3.5 3.5z',
  'calculate': 'M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14z M7 7h3v2H7zm0 4h3v2H7zm0 4h3v2H7zm7-8h3v2h-3zm0 4h3v2h-3zm0 4h3v2h-3z',
  'chair': 'M22 9h-2V7c0-1.1-.9-2-2-2H6c-1.1 0-2 .9-2 2v2H2c-1.1 0-2 .9-2 2v8h2v3h2v-3h16v3h2v-3h2v-8c0-1.1-.9-2-2-2zM6 7h12v2H6V7zm14 10H4v-6h16v6z',
  'science': 'M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-6 11.5L9.5 19H7.2l4.8-6.4V6h2v6.6l4.8 6.4h-2.3L13 14.5z',
  'sports_basketball': 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm0-14c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z',
  'checkroom': 'M21.6 8.2L13 3.6c-.6-.3-1.4-.3-2 0L2.4 8.2c-.6.3-1 .9-1 1.6V20c0 1.1.9 2 2 2h17.2c1.1 0 2-.9 2-2V9.8c0-.7-.4-1.3-1-1.6zm-9.6-3c.3-.2.9-.2 1.2 0l7 3.7c-.5.4-1.2.7-2 .7H5.8c-.8 0-1.5-.3-2-.7l7-3.7zM3.4 20v-8.4c.7.2 1.5.4 2.4.4h12.4c.9 0 1.7-.2 2.4-.4V20H3.4z',
  'watch': 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm0-14c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z',
  'bed': 'M7 13c1.66 0 3-1.34 3-3S8.66 7 7 7s-3 1.34-3 3 1.34 3 3 3zm12-6h-8v7H3V5H1v15h2v-3h18v3h2v-9c0-2.21-1.79-4-4-4z',
  'more_horiz': 'M6 10c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm12 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm-6 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z',
  'verified': 'M23 12l-2.44-2.78.34-3.68-3.61-.82-1.89-3.18L12 3 8.6 1.54 6.71 4.72l-3.61.81.34 3.68L1 12l2.44 2.78-.34 3.69 3.61.82 1.89 3.18L12 21l3.4 1.46 1.89-3.18 3.61-.82-.34-3.68L23 12zm-13 5l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z',
  'mail_outline': 'M22 4H2C.9 4 0 4.9 0 6v12c0 1.1.9 2 2 2h20c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 14H2V8l10 6.25L22 8v10zm-10-6L2 6h20l-10 6z',
  'lock_outline': 'M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zM9 6c0-1.66 1.34-3 3-3s3 1.34 3 3v2H9V6zm9 14H6V10h12v10zm-6-3c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2z',
  'star': 'M12 17.27L18.18 21l-1.64-7.03L22 9.24l-7.19-.61L12 2 9.19 8.63 2 9.24l5.46 4.73L5.82 21z',
  'favorite': 'M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z',
  'favorite_border': 'M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z',
  'local_offer': 'M21.41 11.58l-9-9C12.05 2.22 11.55 2 11 2H4c-1.1 0-2 .9-2 2v7c0 .55.22 1.05.59 1.42l9 9c.36.36.86.58 1.41.58.55 0 1.05-.22 1.41-.59l7-7c.37-.36.59-.86.59-1.41 0-.55-.23-1.06-.59-1.42zM5.5 7C4.67 7 4 6.33 4 5.5S4.67 4 5.5 4 7 4.67 7 5.5 6.33 7 5.5 7z',
  'share': 'M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92 1.61 0 2.92-1.31 2.92-2.92s-1.31-2.92-2.92-2.92z',
  'delete': 'M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z',
  'logout': 'M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z',
  'devices': 'M4 6h18V4H4c-1.1 0-2 .9-2 2v11H0v3h24v-3h-4V6zM20 8h-4c-.55 0-1 .45-1 1v8c0 .55.45 1 1 1h4c.55 0 1-.45 1-1V9c0-.55-.45-1-1-1z',
  'check_circle': 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z',
  'error': 'M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z',
  'rate_review': 'M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zM6 14v-2.42l5.88-5.88c.2-.2.51-.2.71 0l1.71 1.71c.2.2.2.51 0 .71L8.42 14H6zm11.59-6.59l-1.71-1.71c-.2-.2-.2-.51 0-.71l.85-.85c.2-.2.51-.2.71 0l1.71 1.71c.2.2.2.51 0 .71l-.85.85c-.2.2-.51.2-.71 0z',
  'phone': 'M6.62 10.79c1.44 2.83 3.76 5.14 6.59 6.59l2.2-2.2c.27-.27.67-.36 1.02-.24 1.12.37 2.33.57 3.57.57.55 0 1 .45 1 1V20c0 .55-.45 1-1 1-9.39 0-17-7.61-17-17 0-.55.45-1 1-1h3.5c.55 0 1 .45 1 1 0 1.25.2 2.45.57 3.57.11.35.03.74-.25 1.02l-2.2 2.2z',
  'list_alt': 'M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14zM7 10h10v2H7zm0-3h10v2H7zm0 6h10v2H7z',
  'feedback': 'M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-7 12h-2v-2h2v2zm0-4h-2V6h2v4z',
  'help_outline': 'M11 18h2v-2h-2v2zm1-16C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm0-14c-2.21 0-4 1.79-4 4h2c0-1.1.9-2 2-2s2 .9 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5 0-2.21-1.79-4-4-4z',
  'lock': 'M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z',
  'account_balance': 'M4 10h3v7H4zm6 0h3v7h-3zm6 0h3v7h-3zM2 22h20v-2H2zm10-20L2 7h20z',
  'location_on': 'M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z',
  'add_a_photo': 'M3 4V1h2v3h3v2H5v3H3V6H0V4h3zm3 6V7h3V4h7l1.83 2H21c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H6c-1.1 0-2-.9-2-2V10h2zm7 9c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm0-8c1.66 0 3 1.34 3 3s-1.34 3-3 3-3-1.34-3-3 1.34-3 3-3z',
  'visibility': 'M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z',
  'arrow_back_ios_new': 'M11.67 3.87L9.9 2.1 0 12l9.9 9.9 1.77-1.77L3.54 12z',
  'chevron_right': 'M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z'
};

function replaceMaterialIcons(root = document) {
  // Let the browser load the Google Font natively to prevent device-specific SVG layout glitches
}

// ==========================================================================
// 1. MOCK DATABASE & INITIAL STATE
// ==========================================================================

const getProductSvg = (type) => {
  let innerContent = '';
  let stop1 = '#8B7CFF', stop2 = '#6C4CF7';

  if (type === 'ipad') {
    stop1 = '#8B7CFF'; stop2 = '#6C4CF7';
    innerContent = `
      <!-- iPad body -->
      <rect x="35" y="15" width="130" height="120" rx="10" fill="#1C1D21" stroke="#3A3F47" stroke-width="3"/>
      <rect x="42" y="22" width="116" height="106" rx="6" fill="#0A0B0D"/>
      <path d="M42,90 Q70,60 110,110 T158,80 L158,128 L42,128 Z" fill="url(#g)" opacity="0.8"/>
      <circle cx="100" cy="18" r="1.5" fill="#3A3F47"/>
      <rect x="85" y="118" width="30" height="3" rx="1.5" fill="#3A3F47"/>
    `;
  } else if (type === 'book') {
    stop1 = '#FF6B6B'; stop2 = '#FF8E53';
    innerContent = `
      <!-- Stacked pages -->
      <rect x="55" y="25" width="95" height="105" rx="3" fill="#FFFFFF"/>
      <line x1="150" y1="30" x2="150" y2="125" stroke="#E5E9F2" stroke-width="2"/>
      <line x1="55" y1="127" x2="150" y2="127" stroke="#E5E9F2" stroke-width="2"/>
      <!-- Cover -->
      <path d="M50,20 L145,20 C147,20 148,21 148,23 L148,123 C148,125 147,126 145,126 L50,126 C47,126 46,124 46,122 L46,24 C46,22 47,20 50,20 Z" fill="url(#g)"/>
      <rect x="52" y="20" width="6" height="106" fill="rgba(0,0,0,0.15)"/>
      <circle cx="98" cy="73" r="18" fill="none" stroke="#FFFFFF" stroke-width="2" opacity="0.3"/>
      <ellipse cx="98" cy="73" rx="24" ry="8" fill="none" stroke="#FFFFFF" stroke-width="1.5" transform="rotate(30 98 73)" opacity="0.5"/>
      <ellipse cx="98" cy="73" rx="24" ry="8" fill="none" stroke="#FFFFFF" stroke-width="1.5" transform="rotate(-30 98 73)" opacity="0.5"/>
    `;
  } else if (type === 'calculator') {
    stop1 = '#B155FF'; stop2 = '#F55555';
    innerContent = `
      <rect x="50" y="15" width="100" height="120" rx="8" fill="#252830" stroke="#3B404F" stroke-width="2"/>
      <rect x="58" y="23" width="84" height="40" rx="3" fill="#0C0E12"/>
      <path d="M58,43 L142,43" stroke="#2D3139" stroke-width="1"/>
      <path d="M100,23 L100,63" stroke="#2D3139" stroke-width="1"/>
      <path d="M62,55 Q80,25 100,43 T138,30" fill="none" stroke="#00D4A6" stroke-width="2"/>
      <rect x="58" y="70" width="14" height="8" rx="1.5" fill="#3B404F"/>
      <rect x="76" y="70" width="14" height="8" rx="1.5" fill="#3B404F"/>
      <rect x="94" y="70" width="14" height="8" rx="1.5" fill="#3B404F"/>
      <rect x="112" y="70" width="14" height="8" rx="1.5" fill="#3B404F"/>
      <rect x="130" y="70" width="12" height="8" rx="1.5" fill="#FF5E36"/>
      <rect x="58" y="83" width="84" height="44" rx="2" fill="#1C1E24"/>
      <circle cx="68" cy="91" r="2.5" fill="#FFFFFF" opacity="0.7"/>
      <circle cx="80" cy="91" r="2.5" fill="#FFFFFF" opacity="0.7"/>
      <circle cx="92" cy="91" r="2.5" fill="#FFFFFF" opacity="0.7"/>
      <circle cx="68" cy="101" r="2.5" fill="#FFFFFF" opacity="0.7"/>
      <circle cx="80" cy="101" r="2.5" fill="#FFFFFF" opacity="0.7"/>
      <circle cx="92" cy="101" r="2.5" fill="#FFFFFF" opacity="0.7"/>
      <circle cx="68" cy="111" r="2.5" fill="#FFFFFF" opacity="0.7"/>
      <circle cx="80" cy="111" r="2.5" fill="#FFFFFF" opacity="0.7"/>
      <circle cx="92" cy="111" r="2.5" fill="#FFFFFF" opacity="0.7"/>
      <rect x="108" y="87" width="10" height="6" rx="1" fill="url(#g)"/>
      <rect x="122" y="87" width="10" height="6" rx="1" fill="url(#g)"/>
      <rect x="108" y="97" width="10" height="6" rx="1" fill="url(#g)"/>
      <rect x="122" y="97" width="10" height="6" rx="1" fill="url(#g)"/>
      <rect x="108" y="107" width="24" height="10" rx="1" fill="#00D4A6"/>
    `;
  } else if (type === 'chair') {
    stop1 = '#F39C12'; stop2 = '#F1C40F';
    innerContent = `
      <rect x="70" y="20" width="60" height="50" rx="12" fill="url(#g)" stroke="#FFFFFF" stroke-width="2"/>
      <rect x="78" y="28" width="44" height="34" rx="6" fill="rgba(255,255,255,0.15)"/>
      <rect x="62" y="74" width="76" height="12" rx="4" fill="url(#g)" stroke="#FFFFFF" stroke-width="2"/>
      <path d="M96,69 L104,69 L102,75 L98,75 Z" fill="#2E303B"/>
      <rect x="96" y="86" width="8" height="24" fill="#2E303B"/>
      <path d="M70,116 L130,116" stroke="#2E303B" stroke-width="4" stroke-linecap="round"/>
      <path d="M100,110 L100,116" stroke="#2E303B" stroke-width="4"/>
      <circle cx="70" cy="122" r="4" fill="#1C1D22"/>
      <circle cx="100" cy="122" r="4" fill="#1C1D22"/>
      <circle cx="130" cy="122" r="4" fill="#1C1D22"/>
    `;
  } else if (type === 'bike') {
    stop1 = '#00D2B8'; stop2 = '#00F2FE';
    innerContent = `
      <circle cx="55" cy="95" r="22" fill="none" stroke="#2E303B" stroke-width="3"/>
      <circle cx="55" cy="95" r="19" fill="none" stroke="url(#g)" stroke-width="1.5"/>
      <circle cx="145" cy="95" r="22" fill="none" stroke="#2E303B" stroke-width="3"/>
      <circle cx="145" cy="95" r="19" fill="none" stroke="url(#g)" stroke-width="1.5"/>
      <line x1="55" y1="73" x2="55" y2="117" stroke="#9A9EAB" stroke-width="1"/>
      <line x1="33" y1="95" x2="77" y2="95" stroke="#9A9EAB" stroke-width="1"/>
      <line x1="145" y1="73" x2="145" y2="117" stroke="#9A9EAB" stroke-width="1"/>
      <line x1="123" y1="95" x2="167" y2="95" stroke="#9A9EAB" stroke-width="1"/>
      <path d="M55,95 L95,95 L125,60 L78,60 L55,95 Z" fill="none" stroke="url(#g)" stroke-width="3" stroke-linejoin="round"/>
      <path d="M95,95 L88,52" fill="none" stroke="url(#g)" stroke-width="3"/>
      <path d="M125,60 L140,95 M125,60 L120,48 L134,48" fill="none" stroke="#2E303B" stroke-width="3" stroke-linejoin="round"/>
      <path d="M80,52 L96,52" stroke="#2E303B" stroke-width="4" stroke-linecap="round"/>
      <circle cx="95" cy="95" r="6" fill="none" stroke="#2E303B" stroke-width="2"/>
    `;
  } else if (type === 'laptop') {
    stop1 = '#6C4CF7'; stop2 = '#8B7CFF';
    innerContent = `
      <path d="M50,110 L150,110 L154,115 L46,115 Z" fill="#2E303B"/>
      <rect x="52" y="25" width="96" height="85" rx="6" fill="#0A0B0D" stroke="#3A3F47" stroke-width="1.5"/>
      <rect x="58" y="31" width="84" height="73" rx="2" fill="#1C1D22"/>
      <path d="M58,75 Q80,50 110,95 T142,65 L142,104 L58,104 Z" fill="url(#g)" opacity="0.4"/>
      <path d="M38,110 L162,110 C166,110 168,112 168,114 L165,119 C164,122 161,123 158,123 L42,123 C39,123 36,122 35,119 L32,114 C32,112 34,110 38,110 Z" fill="#4B4E5A"/>
      <rect x="90" y="111" width="20" height="2" rx="1" fill="#2E303B"/>
    `;
  } else if (type === 'fridge') {
    stop1 = '#FF5E36'; stop2 = '#FFAE33';
    innerContent = `
      <rect x="65" y="15" width="70" height="120" rx="8" fill="#3A3D46" stroke="#4C505C" stroke-width="2"/>
      <rect x="68" y="18" width="64" height="42" rx="3" fill="url(#g)"/>
      <rect x="124" y="32" width="4" height="18" rx="2" fill="#FFFFFF" opacity="0.6"/>
      <rect x="68" y="64" width="64" height="68" rx="3" fill="url(#g)"/>
      <rect x="124" y="74" width="4" height="24" rx="2" fill="#FFFFFF" opacity="0.6"/>
      <line x1="65" y1="62" x2="135" y2="62" stroke="#2E303B" stroke-width="3"/>
    `;
  } else if (type === 'headphones') {
    stop1 = '#00D4A6'; stop2 = '#00F2FE';
    innerContent = `
      <path d="M60,85 A45,45 0 0,1 140,85" fill="none" stroke="#2E303B" stroke-width="6" stroke-linecap="round"/>
      <path d="M60,85 A45,45 0 0,1 140,85" fill="none" stroke="url(#g)" stroke-width="3" stroke-linecap="round"/>
      <g transform="translate(44,70)">
        <rect x="0" y="0" width="18" height="34" rx="9" fill="url(#g)" stroke="#FFFFFF" stroke-width="2"/>
        <rect x="12" y="6" width="6" height="22" rx="3" fill="#2E303B"/>
      </g>
      <g transform="translate(138,70)">
        <rect x="0" y="0" width="18" height="34" rx="9" fill="url(#g)" stroke="#FFFFFF" stroke-width="2"/>
        <rect x="0" y="6" width="6" height="22" rx="3" fill="#2E303B"/>
      </g>
    `;
  } else {
    stop1 = '#8B7CFF'; stop2 = '#6C4CF7';
    innerContent = `
      <rect x="60" y="35" width="80" height="80" rx="16" fill="url(#g)" stroke="#FFFFFF" stroke-width="2"/>
      <path d="M100,50 L100,100 M75,75 L125,75" stroke="#FFFFFF" stroke-width="6" stroke-linecap="round" opacity="0.3"/>
      <circle cx="100" cy="75" r="20" fill="none" stroke="#FFFFFF" stroke-width="3"/>
    `;
  }

  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="200" height="150" viewBox="0 0 200 150"><defs><linearGradient id="g" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stop-color="${stop1}"/><stop offset="100%" stop-color="${stop2}"/></linearGradient></defs><rect width="100%" height="100%" fill="#F4F5F9"/>${innerContent}</svg>`;
  return 'data:image/svg+xml;base64,' + btoa(svg);
};

const MOCK_CATEGORIES = [
  { id: 'Books', icon: 'menu_book', colorClass: 'cat-g-1' },
  { id: 'Electronics', icon: 'laptop_mac', colorClass: 'cat-g-2' },
  { id: 'Cycles', icon: 'directions_bike', colorClass: 'cat-g-3' },
  { id: 'Calculators', icon: 'calculate', colorClass: 'cat-g-4' },
  { id: 'Furniture', icon: 'chair', colorClass: 'cat-g-5' },
  { id: 'Lab Equipment', icon: 'science', colorClass: 'cat-g-6' },
  { id: 'Sports', icon: 'sports_basketball', colorClass: 'cat-g-7' },
  { id: 'Fashion', icon: 'checkroom', colorClass: 'cat-g-8' },
  { id: 'Accessories', icon: 'watch', colorClass: 'cat-g-9' },
  { id: 'Hostel', icon: 'bed', colorClass: 'cat-g-10' },
  { id: 'Miscellaneous', icon: 'more_horiz', colorClass: 'cat-g-11' }
];

let products = [];
let chats = [];
let users = []; // Synced cloud users list
let myListings = JSON.parse(localStorage.getItem('myListings')) || [];

let currentUser = JSON.parse(localStorage.getItem('currentUser')) || null;

// Application navigation history stack
let navigationStack = ['splash'];
let currentScreen = 'splash';
let activeCategoryFilter = null;
let currentChatId = null;
let uploadedPhotoData = null; // Store temp upload thumbnail
let wishlist = new Set(['p1', 'p3']); // initial pre-liked products

// ==========================================================================
// 2. NAVIGATOR & ROUTER
// ==========================================================================

function navigateTo(screenId, pushToStack = true) {
  const nextScreenEl = document.getElementById(`scr-${screenId}`);
  if (!nextScreenEl) return;

  // Deactivate all screens
  document.querySelectorAll('.screen-container').forEach(el => {
    el.classList.remove('active');
  });

  // Activate new screen
  nextScreenEl.classList.add('active');
  
  if (pushToStack && navigationStack[navigationStack.length - 1] !== screenId) {
    navigationStack.push(screenId);
    if (typeof history !== 'undefined' && history.pushState) {
      history.pushState({ screenId: screenId }, '', `#${screenId}`);
    }
  }
  
  currentScreen = screenId;
  
  // Highlight tab buttons or handle bottom nav visibility
  handleBottomNavState(screenId);
  
  // Update sidebar navigator highlight
  document.querySelectorAll('.nav-screen-link').forEach(el => {
    if (el.getAttribute('data-screen') === screenId) {
      el.classList.add('active');
    } else {
      el.classList.remove('active');
    }
  });

  // Specific Screen Initializers
  if (screenId === 'home') {
    renderHomeListings();
  } else if (screenId === 'chats') {
    renderChatsList();
  } else if (screenId === 'my-listings') {
    renderMyListings('active');
  } else if (screenId === 'tracking') {
    startOrdersListener();
  }
}

function navigateBack() {
  if (typeof history !== 'undefined' && history.state && navigationStack.length > 1) {
    history.back();
  } else {
    if (navigationStack.length <= 1) {
      navigateTo('home');
      return;
    }
    navigationStack.pop(); // Remove current screen
    const prevScreen = navigationStack[navigationStack.length - 1];
    navigateTo(prevScreen, false);
  }
}

function navTabClick(tabId) {
  // Bottom navigation tab triggers
  if (tabId === 'add-listing') {
    navigateTo('add-listing');
  } else {
    navigateTo(tabId);
  }
}

function handleBottomNavState(screenId) {
  const bottomNav = document.getElementById('phone-nav-bar');
  
  // Hide bottom nav on splash, login, register, chat-screen
  const noNavScreens = ['splash', 'login', 'register', 'chat-screen'];
  if (noNavScreens.includes(screenId)) {
    bottomNav.style.display = 'none';
  } else {
    bottomNav.style.display = 'flex';
  }

  // Update active state on the tab items
  document.querySelectorAll('.nav-item').forEach(el => {
    if (el.getAttribute('data-tab') === screenId) {
      el.classList.add('active');
    } else {
      el.classList.remove('active');
    }
  });
}

// Clock updates
function updatePhoneClock() {
  const now = new Date();
  let hours = now.getHours();
  let minutes = now.getMinutes();
  minutes = minutes < 10 ? '0' + minutes : minutes;
  const timeStr = `${hours}:${minutes}`;
  
  const clocks = document.querySelectorAll('#phone-clock');
  clocks.forEach(c => c.textContent = timeStr);
}

// ==========================================================================
// 3. FEATURE IMPLEMENTATIONS: BROWSE & HOME
// ==========================================================================

function renderHomeListings() {
  // Category Scroll
  const catScroll = document.querySelector('.categories-scroll');
  if (catScroll) {
    catScroll.innerHTML = MOCK_CATEGORIES.map(cat => `
      <div class="cat-item-wrapper" onclick="selectCategory('${cat.id}')">
        <div class="cat-item-icon-circle ${cat.colorClass}">
          <span class="material-icons-round">${cat.icon}</span>
        </div>
        <span class="cat-item-label">${cat.id}</span>
      </div>
    `).join('');
  }

  // Featured Grid: filter to those matching category filter if set
  const featuredContainer = document.getElementById('featured-listings-container');
  const recentContainer = document.getElementById('recent-listings-container');
  const trendingContainer = document.getElementById('trending-listings-container');

  let filtered = products;
  if (activeCategoryFilter) {
    filtered = products.filter(p => p.category === activeCategoryFilter);
  }

  // Render cards
  const generateCardsHtml = (items) => {
    if (items.length === 0) {
      return `
        <div class="ds-mini-empty" style="grid-column: span 2; padding: 30px;">
          <span class="material-icons-round text-muted" style="font-size: 32px;">search_off</span>
          <p style="font-size: 12px; color: var(--text-secondary); margin-top: 6px;">No listings in this category.</p>
        </div>
      `;
    }
    return items.map(item => {
      const isFav = wishlist.has(item.id) ? 'active' : '';
      const favIcon = wishlist.has(item.id) ? 'favorite' : 'favorite_border';
      return `
        <div class="product-card" onclick="viewProductDetails('${item.id}')">
          <div class="card-img-container">
            <img src="${item.image}" alt="${item.title}">
            <button class="card-favorite-btn ${isFav}" onclick="event.stopPropagation(); toggleWishlist('${item.id}', this)">
              <span class="material-icons-round">${favIcon}</span>
            </button>
          </div>
          <div class="card-info">
            <div class="card-price-row">
              <span class="card-price">₹${item.price}</span>
              ${item.negotiable ? '<span class="card-negotiable">Neg</span>' : ''}
            </div>
            <span class="card-title">${item.title}</span>
            <div class="card-footer">
              <span class="card-college">${item.college}</span>
              <span class="card-condition">${item.condition}</span>
            </div>
          </div>
        </div>
      `;
    }).join('');
  };

  if (featuredContainer) featuredContainer.innerHTML = generateCardsHtml(filtered.slice(0, 4));
  if (recentContainer) recentContainer.innerHTML = generateCardsHtml(filtered);
  
  // Trending horizontal scroll items
  if (trendingContainer) {
    trendingContainer.innerHTML = filtered.map(item => `
      <div class="product-card" onclick="viewProductDetails('${item.id}')">
        <div class="card-img-container">
          <img src="${item.image}" alt="${item.title}">
        </div>
        <div class="card-info">
          <span class="card-price">₹${item.price}</span>
          <span class="card-title">${item.title}</span>
        </div>
      </div>
    `).join('');
  }
  replaceMaterialIcons(document);
}

function selectCategory(catId) {
  // Toggle filter
  if (activeCategoryFilter === catId) {
    activeCategoryFilter = null;
    showNotification('Cleared category filter');
  } else {
    activeCategoryFilter = catId;
    showNotification(`Filtering by ${catId}`);
  }
  
  // Highlight chips or refresh homepage
  renderHomeListings();
  
  // Navigate back home if they clicked from category page
  if (currentScreen === 'categories') {
    navigateTo('home');
  }
}

function applyQuickFilter(category) {
  // Click handler for homepage chips
  const chips = document.querySelectorAll('.quick-chips .quick-chip');
  chips.forEach(c => {
    if (c.textContent.trim() === category || (category === 'All' && c.textContent.trim() === 'All Items')) {
      c.classList.add('active');
    } else {
      c.classList.remove('active');
    }
  });

  if (category === 'All') {
    activeCategoryFilter = null;
  } else {
    activeCategoryFilter = category;
  }
  renderHomeListings();
}

function toggleWishlist(prodId, btnEl) {
  if (wishlist.has(prodId)) {
    wishlist.delete(prodId);
    btnEl.classList.remove('active');
    btnEl.querySelector('.material-icons-round').textContent = 'favorite_border';
    replaceMaterialIcons(btnEl);
    showNotification('Removed from Wishlist');
  } else {
    wishlist.add(prodId);
    btnEl.classList.add('active');
    btnEl.querySelector('.material-icons-round').textContent = 'favorite';
    replaceMaterialIcons(btnEl);
    showNotification('Added to Wishlist!');
  }
}

// ==========================================================================
// 4. BROWSE DETAILS, SEARCH, AND FILTERS
// ==========================================================================

function viewProductDetails(prodId) {
  const product = products.find(p => p.id === prodId) || myListings.find(p => p.id === prodId);
  if (!product) return;

  navigateTo('product-details');

  document.getElementById('detail-image').src = product.image;
  document.getElementById('detail-title').textContent = product.title;
  document.getElementById('detail-price').textContent = `₹${product.price}`;
  document.getElementById('detail-desc').textContent = product.description || product.desc;
  document.getElementById('detail-negotiable').style.display = product.negotiable ? 'inline-block' : 'none';
  document.getElementById('detail-condition').textContent = product.condition;
  
  // Setup wishlist button
  const wishlistBtn = document.getElementById('detail-wishlist-btn');
  if (wishlist.has(prodId)) {
    wishlistBtn.classList.add('active');
    wishlistBtn.querySelector('.material-icons-round').textContent = 'favorite';
  } else {
    wishlistBtn.classList.remove('active');
    wishlistBtn.querySelector('.material-icons-round').textContent = 'favorite_border';
  }
  replaceMaterialIcons(wishlistBtn);

  // Seller Card details
  const seller = product.seller || { name: currentUser.name, rating: '5.0', college: currentUser.college, initials: currentUser.initials };
  document.getElementById('detail-seller-name').textContent = seller.name;
  document.getElementById('detail-seller-college').textContent = seller.college;
  
  const avatarEl = document.getElementById('detail-seller-avatar');
  avatarEl.textContent = seller.initials;

  // Store active product context in chat session details
  document.getElementById('scr-product-details').dataset.activeProductId = prodId;

  // Render related items
  const relatedContainer = document.getElementById('related-listings-container');
  if (relatedContainer) {
    const related = products.filter(p => p.category === product.category && p.id !== product.id);
    if (related.length === 0) {
      relatedContainer.innerHTML = `<span style="font-size:12px; color:var(--text-muted); padding:10px;">No other listings in this category.</span>`;
    } else {
      relatedContainer.innerHTML = related.map(item => `
        <div class="product-card" onclick="viewProductDetails('${item.id}')">
          <div class="card-img-container">
            <img src="${item.image}" alt="${item.title}">
          </div>
          <div class="card-info">
            <span class="card-price">₹${item.price}</span>
            <span class="card-title">${item.title}</span>
          </div>
        </div>
      `).join('');
    }
  }
  replaceMaterialIcons(document);
}

function toggleDetailWishlist() {
  const prodId = document.getElementById('scr-product-details').dataset.activeProductId;
  const wishlistBtn = document.getElementById('detail-wishlist-btn');
  if (!prodId) return;

  toggleWishlist(prodId, wishlistBtn);
}

// Search Page interactions
function updatePriceSlider(val) {
  document.getElementById('slider-max-display').textContent = `₹${val}`;
}

function toggleFilterChip(el, type) {
  // Toggle selection on chips
  const parent = el.parentElement;
  parent.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
  el.classList.add('active');
}

function resetFilters() {
  document.getElementById('main-search-input').value = '';
  document.getElementById('filter-price-range').value = 500;
  updatePriceSlider(500);
  
  // reset chips
  document.querySelectorAll('.filter-chip').forEach(c => c.classList.remove('active'));
  document.querySelectorAll('#filter-category-chips .filter-chip')[0].classList.add('active');
  document.querySelectorAll('#filter-condition-chips .filter-chip')[0].classList.add('active');
  document.querySelectorAll('#filter-sort-chips .filter-chip')[0].classList.add('active');

  showNotification('Filters Reset');
}

function applyFilters() {
  const query = document.getElementById('main-search-input').value.toLowerCase();
  const activeCategoryChip = document.querySelector('#filter-category-chips .filter-chip.active').textContent.trim();
  const maxPrice = parseFloat(document.getElementById('filter-price-range').value);
  const condition = document.querySelector('#filter-condition-chips .filter-chip.active').textContent.trim();
  
  // Apply logic in home
  activeCategoryFilter = (activeCategoryChip === 'All') ? null : activeCategoryChip;
  
  // Filter products matching search criteria
  let filtered = products.filter(p => {
    const matchesQuery = p.title.toLowerCase().includes(query) || p.description.toLowerCase().includes(query);
    const matchesCategory = !activeCategoryFilter || p.category === activeCategoryFilter;
    const matchesPrice = p.price <= maxPrice;
    const matchesCondition = condition === 'Any' || p.condition === condition;
    return matchesQuery && matchesCategory && matchesPrice && matchesCondition;
  });

  navigateTo('home');
  showNotification(`Found ${filtered.length} listings`);

  // Render home with filtered result
  const featuredContainer = document.getElementById('featured-listings-container');
  const recentContainer = document.getElementById('recent-listings-container');
  
  const generateCardsHtml = (items) => {
    if (items.length === 0) {
      return `
        <div class="ds-mini-empty" style="grid-column: span 2; padding: 40px;">
          <span class="material-icons-round text-muted" style="font-size: 32px;">search_off</span>
          <p style="font-size: 12px; color: var(--text-secondary); margin-top: 6px;">No listings matched your criteria.</p>
        </div>
      `;
    }
    return items.map(item => `
      <div class="product-card" onclick="viewProductDetails('${item.id}')">
        <div class="card-img-container">
          <img src="${item.image}" alt="${item.title}">
        </div>
        <div class="card-info">
          <span class="card-price">₹${item.price}</span>
          <span class="card-title">${item.title}</span>
        </div>
      </div>
    `).join('');
  };

  featuredContainer.innerHTML = generateCardsHtml(filtered.slice(0, 2));
  recentContainer.innerHTML = generateCardsHtml(filtered);
  replaceMaterialIcons(document);
}

function runSearch() {
  // Live filter as user types on search bar
  const query = document.getElementById('main-search-input').value.toLowerCase();
  console.log("Searching: " + query);
}

// ==========================================================================
// 5. AUTH (LOGIN & REGISTER)
// ==========================================================================

function loginUser() {
  localStorage.setItem('currentUser', JSON.stringify(currentUser));
  showNotification('Logged in successfully!');
  navigateTo('home');
}

function registerUser() {
  const name = document.getElementById('reg-name').value || 'New Student';
  const email = document.getElementById('reg-email').value || 'student@university.edu';
  const college = document.getElementById('reg-college').value || 'Stanford University';
  
  currentUser.name = name;
  currentUser.email = email;
  currentUser.college = college;
  currentUser.initials = name.split(' ').map(n=>n[0]).join('').toUpperCase();

  // Update profile avatar
  document.querySelectorAll('.profile-name').forEach(el => el.textContent = currentUser.name);
  document.querySelectorAll('.profile-email').forEach(el => el.textContent = currentUser.email);
  document.querySelectorAll('.profile-avatar-large').forEach(el => el.textContent = currentUser.initials);

  localStorage.setItem('currentUser', JSON.stringify(currentUser));
  showNotification('Welcome to CampusConnect!');
  navigateTo('home');
}

function logoutUser() {
  localStorage.removeItem('currentUser');
  navigationStack = ['login'];
  navigateTo('login');
  showNotification('Logged out successfully.');
}

// ==========================================================================
// 6. SELL: ADD LISTING
// ==========================================================================

let uploadedPhotoURL = null;

function triggerRealPhotoUpload() {
  document.getElementById('product-photo-input').click();
}

async function handleRealPhotoUpload(event) {
  const file = event.target.files[0];
  if (!file) return;

  // Show local preview immediately for instant UX response
  const reader = new FileReader();
  reader.onload = function(e) {
    const preview = document.getElementById('upload-preview');
    if (preview) {
      preview.style.display = 'grid';
      preview.innerHTML = `
        <div class="preview-thumb" style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; overflow: hidden; border-radius: 12px;">
          <img src="${e.target.result}" alt="Uploaded photo" style="width: 100%; height: 100%; object-fit: cover;">
        </div>
      `;
    }
  };
  reader.readAsDataURL(file);

  // Upload to Firebase Storage in the background
  try {
    showNotification('Uploading image to cloud storage...');
    const path = `items/${Date.now()}_${file.name}`;
    uploadedPhotoURL = await uploadFileToFirebase(file, path);
    showNotification('Image uploaded to Firebase Storage!');
  } catch (error) {
    console.error("Firebase Storage upload failed:", error);
    showNotification(`Upload failed: ${error.message}`);
  }
}

async function uploadFileToFirebase(file, path) {
  if (typeof firebase === 'undefined' || !firebase.storage) {
    throw new Error("Firebase Storage SDK is not loaded.");
  }
  const storageRef = firebase.storage().ref();
  const fileRef = storageRef.child(path);
  const snapshot = await fileRef.put(file);
  const downloadURL = await snapshot.ref.getDownloadURL();
  return downloadURL;
}

function submitNewListing() {
  const title = document.getElementById('add-title').value;
  const category = document.getElementById('add-category').value;
  const price = parseFloat(document.getElementById('add-price').value);
  const condition = document.getElementById('add-condition').value;
  const desc = document.getElementById('add-desc').value;
  const college = document.getElementById('add-college').value;
  const negotiable = document.getElementById('add-negotiable').checked;

  if (!title || !price) {
    showErrorDialog('Missing fields! Please enter a title and price.');
    return;
  }

  // Create new listing object
  const newId = 'p' + (products.length + 1);
  const image = uploadedPhotoURL || 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="200" height="150" viewBox="0 0 200 150"><rect width="100%" height="100%" fill="%238B7CFF"/><text x="50%" y="55%" font-family="Poppins" font-weight="bold" font-size="14" fill="white" text-anchor="middle">Campus Item</text></svg>';

  const newItem = {
    id: newId,
    title,
    price,
    negotiable,
    condition,
    category,
    college,
    description: desc,
    image,
    seller: { name: currentUser.fullName || currentUser.name, rating: '5.0', college: currentUser.college, initials: currentUser.initials }
  };

  // Push to products database
  products.unshift(newItem);
  saveSharedProducts(); // SYNC DATABASE

  // Push to user listings
  myListings.unshift({
    id: newId + 'my',
    title,
    price,
    views: 0,
    status: 'active',
    category,
    condition,
    desc,
    image
  });
  localStorage.setItem('myListings', JSON.stringify(myListings));

  // Reset form
  document.getElementById('add-title').value = '';
  document.getElementById('add-price').value = '';
  document.getElementById('add-desc').value = '';
  document.getElementById('upload-preview').style.display = 'none';
  uploadedPhotoURL = null;

  showSuccessDialog('Success! Your listing has been published to the student catalog.');
  navigateTo('home');
}

// ==========================================================================
// 7. CHATS & MESSAGING
// ==========================================================================

function renderChatsList() {
  const container = document.getElementById('chats-list');
  if (!container) return;

  container.innerHTML = chats.map(chat => {
    const unreadHtml = chat.unread > 0 ? `<span class="chat-badge">${chat.unread}</span>` : '';
    const onlineClass = chat.online ? 'online' : '';
    return `
      <div class="chat-item" onclick="openChatThread('${chat.id}')">
        <div class="chat-avatar ${onlineClass}">${chat.avatar}</div>
        <div class="chat-details">
          <div class="chat-name-row">
            <span class="chat-name">${chat.name}</span>
            <span class="chat-time">${chat.time}</span>
          </div>
          <div class="chat-msg-row">
            <span class="chat-preview">${chat.lastMsg}</span>
            ${unreadHtml}
          </div>
        </div>
      </div>
    `;
  }).join('');
  replaceMaterialIcons(container);
}

function openChatThread(chatId) {
  const chat = chats.find(c => c.id === chatId);
  if (!chat) return;

  currentChatId = chatId;
  chat.unread = 0; // Clear read count

  navigateTo('chat-screen');

  document.getElementById('active-chat-name').textContent = chat.name;
  document.getElementById('active-chat-avatar').textContent = chat.avatar;
  
  // Render message log
  renderActiveBubbles(chat);
}

function renderActiveBubbles(chat) {
  const container = document.getElementById('chat-bubble-container');
  if (!container) return;

  container.innerHTML = chat.messages.map(m => {
    const isOut = m.sender === 'me' ? 'outgoing' : 'incoming';
    return `
      <div class="bubble-row ${isOut}">
        <div class="bubble">
          <span>${m.text}</span>
          <div class="bubble-time">${m.time || '10:14 AM'}</div>
        </div>
      </div>
    `;
  }).join('');

  // Scroll to bottom
  container.scrollTop = container.scrollHeight;
  replaceMaterialIcons(container);
}

function sendChatMessage() {
  const input = document.getElementById('chat-message-input');
  const text = input.value.trim();
  if (!text || !currentChatId) return;

  const chat = chats.find(c => c.id === currentChatId);
  if (!chat) return;

  // Push outgoing message
  const now = new Date();
  const timeStr = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  
  chat.messages.push({ sender: 'me', text, time: timeStr });
  chat.lastMsg = text;
  chat.time = 'Just Now';
  
  input.value = '';
  renderActiveBubbles(chat);

  // Trigger typing simulation after 1.5 seconds
  const typingEl = document.getElementById('typing-indicator');
  typingEl.style.display = 'block';
  document.getElementById('chat-bubble-container').scrollTop = document.getElementById('chat-bubble-container').scrollHeight;

  setTimeout(() => {
    typingEl.style.display = 'none';
    
    // Custom responses based on question contents
    let reply = "Yes, let's meet up at the Bookstore tomorrow afternoon.";
    if (text.toLowerCase().includes('price') || text.toLowerCase().includes('low') || text.toLowerCase().includes('offer')) {
      reply = "The lowest I can go is $470. I already have two other offers.";
    } else if (text.toLowerCase().includes('where') || text.toLowerCase().includes('meet')) {
      reply = "How about the Tressider Union courtyard near Starbucks?";
    }

    chat.messages.push({ sender: 'them', text: reply, time: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) });
    chat.lastMsg = reply;
    
    renderActiveBubbles(chat);
  }, 2000);
}

function handleChatInputKey(event) {
  if (event.key === 'Enter') {
    sendChatMessage();
  }
}

function startSellerChat() {
  const prodId = document.getElementById('scr-product-details').dataset.activeProductId;
  const product = products.find(p => p.id === prodId);
  if (!product) return;

  // Find if chat already exists
  let chat = chats.find(c => c.product === product.title);
  if (!chat) {
    const newChatId = 'c' + (chats.length + 1);
    chat = {
      id: newChatId,
      name: product.seller.name,
      avatar: product.seller.initials,
      online: true,
      lastMsg: `Hi, is the ${product.title} still available?`,
      time: 'Just Now',
      unread: 0,
      product: product.title,
      messages: [
        { sender: 'me', text: `Hi, is the ${product.title} still available?`, time: 'Just Now' }
      ]
    };
    chats.unshift(chat);
    saveSharedChats(); // SYNC DATABASE
  }
  openChatThread(chat.id);
}

function startOfferChat() {
  const prodId = document.getElementById('scr-product-details').dataset.activeProductId;
  const product = products.find(p => p.id === prodId);
  if (!product) return;

  // Direct to bottom sheet trigger for offer choices
  showBottomSheet('Make Offer Option', [
    { label: `Offer $${Math.round(product.price * 0.9)} (10% Off)`, action: () => submitOffer(Math.round(product.price * 0.9)) },
    { label: `Offer $${Math.round(product.price * 0.85)} (15% Off)`, action: () => submitOffer(Math.round(product.price * 0.85)) },
    { label: 'Custom Offer Amount', action: () => showNotification('Custom offer entered!') }
  ]);
}

function submitOffer(amount) {
  closeBottomSheet();
  startSellerChat();
  
  // Append offer message
  const chat = chats.find(c => c.id === currentChatId);
  if (!chat) return;

  chat.messages.push({ sender: 'me', text: `Hey, I would like to offer ₹${amount} for this item.`, time: 'Just Now' });
  renderActiveBubbles(chat);
  saveSharedChats(); // SYNC DATABASE
}

function runChatSearch() {
  const query = document.getElementById('chat-search').value.toLowerCase();
  const items = document.querySelectorAll('#chats-list .chat-item');
  
  items.forEach((item, idx) => {
    const chat = chats[idx];
    if (chat.name.toLowerCase().includes(query) || chat.lastMsg.toLowerCase().includes(query)) {
      item.style.display = 'flex';
    } else {
      item.style.display = 'none';
    }
  });
}

// ==========================================================================
// 8. MY LISTINGS MANAGER
// ==========================================================================

function renderMyListings(statusFilter = 'active') {
  const container = document.getElementById('my-listings-container');
  if (!container) return;

  const filtered = myListings.filter(l => l.status === statusFilter);

  if (filtered.length === 0) {
    container.innerHTML = `
      <div class="ds-mini-empty" style="padding: 40px; margin-top: 20px;">
        <span class="material-icons-round text-muted" style="font-size: 40px;">category</span>
        <p style="font-size: 13px; color: var(--text-secondary); margin-top: 8px;">No listings under ${statusFilter}.</p>
      </div>
    `;
    replaceMaterialIcons(container);
    return;
  }

  container.innerHTML = filtered.map(item => `
    <div class="my-listing-card" id="myl-${item.id}">
      <img src="${item.image}" alt="${item.title}" class="my-listing-img">
      <div class="my-listing-details">
        <span class="my-listing-title">${item.title}</span>
        <span class="my-listing-price">₹${item.price}</span>
        <div class="my-listing-meta">
          <span class="my-listing-badge ${item.status}">${item.status}</span>
          <span class="my-listing-views">
            <span class="material-icons-round icon-xs">visibility</span> ${item.views} Views
          </span>
        </div>
      </div>
      <div class="my-listing-actions">
        <button class="btn-back" onclick="deleteMyListing('${item.id}')" title="Delete listing">
          <span class="material-icons-round text-red" style="font-size: 16px;">delete</span>
        </button>
      </div>
    </div>
  `).join('');
  replaceMaterialIcons(container);
}

function switchMyListingsTab(btnEl, tabName) {
  const parent = btnEl.parentElement;
  parent.querySelectorAll('.listing-tab').forEach(t => t.classList.remove('active'));
  btnEl.classList.add('active');
  renderMyListings(tabName);
}

function deleteMyListing(listingId) {
  // Confirm deletion
  myListings = myListings.filter(l => l.id !== listingId);
  localStorage.setItem('myListings', JSON.stringify(myListings));
  
  // also filter from products
  const coreId = listingId.replace('my', '');
  products = products.filter(p => p.id !== coreId);
  saveSharedProducts(); // SYNC DATABASE

  showNotification('Listing deleted successfully');
  
  // Rerender active list
  const activeTab = document.querySelector('.listing-tab.active').textContent.trim().toLowerCase();
  renderMyListings(activeTab);
  renderHomeListings();
}

// ==========================================================================
// 9. OVERLAYS & FEEDBACK MODALS (SNACKBARS, SUCCESS, ERROR, BOTTOM SHEETS)
// ==========================================================================

function showNotification(msg) {
  const snackbar = document.getElementById('comp-snackbar');
  document.getElementById('snackbar-msg').textContent = msg;
  
  snackbar.classList.add('active');
  
  // Auto dismiss
  setTimeout(() => {
    snackbar.classList.remove('active');
  }, 3000);
}

function showSuccessDialog(msg) {
  const dialog = document.getElementById('comp-success-dialog');
  document.getElementById('success-dialog-msg').textContent = msg;
  dialog.classList.add('active');
}

function showErrorDialog(msg) {
  const dialog = document.getElementById('comp-error-dialog');
  document.getElementById('error-dialog-msg').textContent = msg;
  dialog.classList.add('active');
}

function closeModal(modalId) {
  document.getElementById(modalId).classList.remove('active');
}

// Bottom sheet actions
function showBottomSheet(title, items) {
  const sheet = document.getElementById('comp-bottom-sheet');
  document.getElementById('bottom-sheet-title').textContent = title;
  
  const listEl = document.getElementById('bottom-sheet-items');
  listEl.innerHTML = items.map((item, idx) => `
    <div class="bottom-sheet-item" onclick="triggerSheetAction(${idx})">${item.label}</div>
  `).join('');

  // Store actions reference
  window._activeSheetActions = items.map(i => i.action);
  
  sheet.classList.add('active');
}

function triggerSheetAction(idx) {
  if (window._activeSheetActions && window._activeSheetActions[idx]) {
    window._activeSheetActions[idx]();
  }
}

function closeBottomSheet() {
  document.getElementById('comp-bottom-sheet').classList.remove('active');
}

function closeBottomSheetOnBgClick(e) {
  if (e.target.id === 'comp-bottom-sheet') {
    closeBottomSheet();
  }
}

// Skeleton state switcher
let isSkeletonActive = false;
function toggleSkeletonState() {
  isSkeletonActive = !isSkeletonActive;
  const cards = document.querySelectorAll('.product-card');
  
  cards.forEach(card => {
    if (isSkeletonActive) {
      // replace innerHTML with skeletons
      card.dataset.cachedHtml = card.innerHTML;
      card.innerHTML = `
        <div class="skeleton-preview-card" style="width: 100%; border: none; padding: 0;">
          <div class="skeleton-shimmer skeleton-img" style="height: 110px; border-radius: 0;"></div>
          <div style="padding: 10px;">
            <div class="skeleton-shimmer skeleton-line-title" style="height: 12px; margin-bottom: 6px; width: 60%;"></div>
            <div class="skeleton-shimmer skeleton-line-sub" style="height: 8px; width: 40%;"></div>
          </div>
        </div>
      `;
    } else {
      if (card.dataset.cachedHtml) {
        card.innerHTML = card.dataset.cachedHtml;
      }
    }
  });

  showNotification(isSkeletonActive ? 'Skeleton loaded' : 'Skeleton cleared');
}

// ==========================================================================
// 9.5 SECURE CHECKOUT HANDLERS
// ==========================================================================

let checkoutActiveDelivery = 'pickup';
let checkoutActivePayment = 'upi';

function openCheckout() {
  const prodId = document.getElementById('scr-product-details').dataset.activeProductId;
  const product = products.find(p => p.id === prodId) || myListings.find(p => p.id === prodId);
  if (!product) return;

  navigateTo('checkout');

  document.getElementById('checkout-item-image').src = product.image;
  document.getElementById('checkout-item-title').textContent = product.title;
  document.getElementById('checkout-item-price').textContent = `₹${product.price}`;

  // Reset checkout options
  checkoutActiveDelivery = 'pickup';
  checkoutActivePayment = 'upi';

  document.querySelectorAll('#delivery-pickup, #delivery-ship').forEach(el => el.classList.remove('active'));
  document.getElementById('delivery-pickup').classList.add('active');
  document.getElementById('delivery-pickup').querySelector('input').checked = true;

  document.querySelectorAll('#payment-upi, #payment-cash').forEach(el => el.classList.remove('active'));
  document.getElementById('payment-upi').classList.add('active');
  document.getElementById('payment-upi').querySelector('input').checked = true;

  updateCheckoutSummary(product.price);
}

function selectCheckoutDelivery(method) {
  checkoutActiveDelivery = method;
  document.querySelectorAll('#delivery-pickup, #delivery-ship').forEach(el => el.classList.remove('active'));
  
  const selectedEl = document.getElementById(`delivery-${method}`);
  selectedEl.classList.add('active');
  selectedEl.querySelector('input').checked = true;

  const prodId = document.getElementById('scr-product-details').dataset.activeProductId;
  const product = products.find(p => p.id === prodId) || myListings.find(p => p.id === prodId);
  if (product) updateCheckoutSummary(product.price);
}

function selectCheckoutPayment(method) {
  checkoutActivePayment = method;
  document.querySelectorAll('#payment-upi, #payment-cash').forEach(el => el.classList.remove('active'));
  
  const selectedEl = document.getElementById(`payment-${method}`);
  selectedEl.classList.add('active');
  selectedEl.querySelector('input').checked = true;
}

function updateCheckoutSummary(subtotal) {
  const deliveryFee = checkoutActiveDelivery === 'ship' ? 40 : 0;
  const total = subtotal + deliveryFee;

  document.getElementById('summary-subtotal').textContent = `₹${subtotal}`;
  document.getElementById('summary-delivery').textContent = `₹${deliveryFee}`;
  document.getElementById('summary-total').textContent = `₹${total}`;
}

let trackingTimeouts = [];
let userLatitude = null;
let userLongitude = null;

function detectUserLocation() {
  const lbl = document.getElementById('lbl-location-coords');
  if (!navigator.geolocation) {
    lbl.textContent = "Geolocation is not supported by your browser.";
    return;
  }
  
  lbl.textContent = "Detecting GPS coordinates...";
  navigator.geolocation.getCurrentPosition(
    (position) => {
      userLatitude = position.coords.latitude.toFixed(4);
      userLongitude = position.coords.longitude.toFixed(4);
      lbl.innerHTML = `<span class="text-success" style="font-weight:700;">📍 Pinned: ${userLatitude}° N, ${userLongitude}° E</span>`;
      showNotification("Location pinned successfully for delivery!");
    },
    (error) => {
      lbl.textContent = "Location access denied. Using default campus address.";
      console.warn("Location error:", error);
    }
  );
}

let currentTrackingOrders = [];
let selectedTrackingTab = 0; // 0: Active, 1: Completed, 2: Cancelled
let selectedTrackingOrderId = null;
let ordersListener = null;

async function placeOrder() {
  const prodId = document.getElementById('scr-product-details').dataset.activeProductId;
  const product = products.find(p => p.id === prodId) || myListings.find(p => p.id === prodId);
  if (!product) return;

  if (!currentUser || !currentUser.uid) {
    showNotification("Please log in to place an order.");
    return;
  }

  showNotification("Placing your order...");

  try {
    const orderId = db.collection('orders').doc().id;
    const orderDoc = {
      orderId: orderId,
      buyerUID: currentUser.uid,
      sellerUID: product.sellerUid || product.uid || 'dummy_seller',
      listingID: product.id,
      status: 'Pending',
      createdAt: firebase.firestore.FieldValue.serverTimestamp(),
      title: product.title,
      price: product.price,
      image: product.image || (product.images && product.images[0]) || ''
    };

    await db.collection('orders').doc(orderId).set(orderDoc);

    // Update listing status to sold
    await db.collection('items').doc(product.id).update({ status: 'sold' });

    showNotification("Order placed successfully!");
    
    // Automatically load tracking tab
    navigateTo('tracking');
  } catch (error) {
    console.error("Error placing order:", error);
    showNotification("Error placing order: " + error.message);
  }
}

function startOrdersListener() {
  if (ordersListener) {
    ordersListener(); // Detach previous listener
    ordersListener = null;
  }

  if (!currentUser || !currentUser.uid) {
    renderTrackingState([]);
    return;
  }

  ordersListener = db.collection('orders')
    .where('buyerUID', '==', currentUser.uid)
    .onSnapshot(snapshot => {
      const orders = [];
      snapshot.forEach(doc => {
        const data = doc.data();
        data.id = doc.id;
        orders.push(data);
      });
      currentTrackingOrders = orders;
      renderTrackingState(orders);
    }, error => {
      console.error("Error fetching orders:", error);
    });
}

function renderTrackingState(orders) {
  const activeOrders = orders.filter(o => o.status !== 'Delivered' && o.status !== 'Cancelled');
  const completedOrders = orders.filter(o => o.status === 'Delivered');
  const cancelledOrders = orders.filter(o => o.status === 'Cancelled');

  const emptyStateEl = document.getElementById('tracking-empty-state');
  const listContainerEl = document.getElementById('tracking-list-container');
  const detailsViewEl = document.getElementById('tracking-details-view');

  // Auto select if there is exactly 1 active order and no selected order yet
  if (selectedTrackingTab === 0 && activeOrders.length === 1 && !selectedTrackingOrderId) {
    selectedTrackingOrderId = activeOrders[0].id;
  }

  if (selectedTrackingOrderId) {
    // Show detailed tracking view for selected order
    emptyStateEl.style.display = 'none';
    listContainerEl.style.display = 'none';
    detailsViewEl.style.display = 'block';

    const order = orders.find(o => o.id === selectedTrackingOrderId);
    if (order) {
      updateTrackingTimeline(order);
    } else {
      selectedTrackingOrderId = null;
      renderTrackingState(orders);
    }
    return;
  }

  // If no selected order, show list or empty state
  detailsViewEl.style.display = 'none';

  let currentList = [];
  let emptyTitle = '';
  let emptyDesc = '';
  let showBrowseButton = false;

  if (selectedTrackingTab === 0) {
    currentList = activeOrders;
    emptyTitle = "No Active Orders";
    emptyDesc = "You haven't placed any orders yet.";
    showBrowseButton = true;
  } else if (selectedTrackingTab === 1) {
    currentList = completedOrders;
    emptyTitle = "No Completed Orders";
    emptyDesc = "Your completed orders will show up here.";
    showBrowseButton = false;
  } else {
    currentList = cancelledOrders;
    emptyTitle = "No Cancelled Orders";
    emptyDesc = "Your cancelled orders will show up here.";
    showBrowseButton = false;
  }

  if (currentList.length === 0) {
    emptyStateEl.style.display = 'block';
    listContainerEl.style.display = 'none';
    emptyStateEl.querySelector('h4').textContent = emptyTitle;
    emptyStateEl.querySelector('p').textContent = emptyDesc;
    emptyStateEl.querySelector('.btn-app').style.display = showBrowseButton ? 'inline-block' : 'none';
  } else {
    emptyStateEl.style.display = 'none';
    listContainerEl.style.display = 'block';
    renderOrdersListView(currentList);
  }
}

function switchTrackingTab(tabIndex) {
  selectedTrackingTab = tabIndex;
  selectedTrackingOrderId = null;
  
  const tabActive = document.getElementById('tab-active-orders');
  const tabCompleted = document.getElementById('tab-completed-orders');
  const tabCancelled = document.getElementById('tab-cancelled-orders');
  
  // Reset all
  [tabActive, tabCompleted, tabCancelled].forEach(el => {
    if (el) {
      el.style.borderBottomColor = 'transparent';
      el.style.color = 'var(--text-secondary)';
      el.style.fontWeight = '500';
    }
  });

  const selectedEl = tabIndex === 0 ? tabActive : (tabIndex === 1 ? tabCompleted : tabCancelled);
  if (selectedEl) {
    selectedEl.style.borderBottomColor = 'var(--primary)';
    selectedEl.style.color = 'var(--primary)';
    selectedEl.style.fontWeight = '700';
  }
  
  renderTrackingState(currentTrackingOrders);
}

function backToTrackingList() {
  selectedTrackingOrderId = null;
  renderTrackingState(currentTrackingOrders);
}

function handleTrackingBack() {
  if (selectedTrackingOrderId) {
    backToTrackingList();
  } else {
    navigateTo('home');
  }
}

function clickCancelOrder() {
  document.getElementById('comp-cancel-dialog').classList.add('active');
}

function closeCancelDialog() {
  document.getElementById('comp-cancel-dialog').classList.remove('active');
}

async function confirmCancelOrder() {
  closeCancelDialog();
  if (!selectedTrackingOrderId) return;
  
  const order = currentTrackingOrders.find(o => o.id === selectedTrackingOrderId);
  if (!order) return;

  showNotification("Cancelling your order...");

  try {
    const batch = db.batch();
    
    // 1. Update order document status
    const orderRef = db.collection('orders').doc(order.id);
    const cancelledByRole = (currentUser.uid === order.buyerUID) ? 'Buyer' : 'Seller';
    batch.update(orderRef, {
      status: 'Cancelled',
      cancelledBy: cancelledByRole,
      cancelledAt: firebase.firestore.FieldValue.serverTimestamp()
    });

    // 2. Make the product listing active again
    const itemRef = db.collection('items').doc(order.listingID);
    batch.update(itemRef, {
      status: 'active'
    });

    // 3. Create notifications
    const buyerNotificationRef = db.collection('notifications').doc();
    const sellerNotificationRef = db.collection('notifications').doc();

    const buyerNotifBody = (cancelledByRole === 'Buyer')
      ? `You cancelled your order for ${order.title}.`
      : `Seller cancelled your order for ${order.title}.`;
    
    const sellerNotifBody = (cancelledByRole === 'Buyer')
      ? `Buyer cancelled the order for ${order.title}.`
      : `You cancelled the order for ${order.title}.`;

    batch.set(buyerNotificationRef, {
      userUid: order.buyerUID,
      title: 'Order Cancelled',
      body: buyerNotifBody,
      type: 'order',
      referenceId: order.id,
      read: false,
      createdAt: firebase.firestore.FieldValue.serverTimestamp()
    });

    batch.set(sellerNotificationRef, {
      userUid: order.sellerUID,
      title: 'Order Cancelled',
      body: sellerNotifBody,
      type: 'order',
      referenceId: order.id,
      read: false,
      createdAt: firebase.firestore.FieldValue.serverTimestamp()
    });

    await batch.commit();
    showNotification("Order cancelled successfully.");
    selectedTrackingOrderId = null;
  } catch (error) {
    console.error("Error cancelling order:", error);
    showNotification("Error cancelling order: " + error.message);
  }
}

function renderOrdersListView(ordersList) {
  const container = document.getElementById('tracking-orders-list-view');
  if (!container) return;

  if (ordersList.length === 0) {
    container.innerHTML = `<div style="text-align:center; padding: 24px; color: var(--text-secondary);">No orders found.</div>`;
    return;
  }

  container.innerHTML = ordersList.map(order => {
    const statusColor = getStatusColor(order.status);
    const orderImage = order.image || 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100';
    
    let displayStatus = order.status;
    if (order.status === 'Cancelled' && order.cancelledBy) {
      displayStatus = `Cancelled by ${order.cancelledBy}`;
    }

    return `
      <div class="card shadow-premium" style="margin-bottom: 12px; padding: 12px; cursor: pointer; display: flex; align-items: center; border: 1px solid var(--border-light); border-radius: 16px; background: var(--bg-card);" onclick="selectTrackingOrder('${order.id}')">
        <img src="${orderImage}" style="width: 50px; height: 50px; border-radius: 12px; object-fit: cover; margin-right: 12px;" onerror="this.src='https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=100'"/>
        <div style="flex: 1;">
          <h5 style="font-weight: 700; font-size: 14px; margin-bottom: 4px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 180px; color: var(--text-primary);">${order.title}</h5>
          <span style="font-weight: 800; color: var(--primary); font-size: 13px;">₹${order.price}</span>
          <div style="margin-top: 6px;">
            <span style="background: ${statusColor}1A; color: ${statusColor}; font-size: 10px; font-weight: 700; padding: 4px 8px; border-radius: 6px; display: inline-block;">${displayStatus}</span>
          </div>
        </div>
        <span class="material-icons-round" style="color: var(--text-secondary); font-size: 16px;">chevron_right</span>
      </div>
    `;
  }).join('');
}

function selectTrackingOrder(orderId) {
  selectedTrackingOrderId = orderId;
  renderTrackingState(currentTrackingOrders);
}

function getStatusColor(status) {
  switch (status) {
    case 'Delivered':
      return '#4CAF50';
    case 'Cancelled':
      return '#9E9E9E';
    case 'On the Way':
    case 'Picked Up':
      return '#2196F3';
    case 'Preparing':
    case 'Accepted':
      return '#FF9800';
    default:
      return '#9E9E9E';
  }
}

function getStatusStep(status) {
  switch (status) {
    case 'Pending':
      return 0;
    case 'Accepted':
      return 1;
    case 'Preparing':
      return 2;
    case 'Picked Up':
      return 3;
    case 'On the Way':
      return 4;
    case 'Delivered':
      return 5;
    default:
      return 0;
  }
}

function updateTrackingTimeline(order) {
  const currentStep = getStatusStep(order.status);
  const isCancelled = order.status === 'Cancelled';
  const isBuyer = currentUser.uid === order.buyerUID;

  const canCancel = order.status === 'Pending' || order.status === 'Accepted' || order.status === 'Preparing';
  const showBuyerOnWayWarning = isBuyer && !canCancel && order.status !== 'Delivered' && order.status !== 'Cancelled';

  // Toggle buttons
  const btnCancel = document.getElementById('btn-cancel-order');
  const divWarning = document.getElementById('buyer-cancel-warning');
  if (btnCancel && divWarning) {
    btnCancel.style.display = canCancel ? 'block' : 'none';
    divWarning.style.display = showBuyerOnWayWarning ? 'block' : 'none';
  }

  let markerX = 30;
  let markerY = 80;
  let showMarker = !isCancelled;
  let statusDesc = '';

  switch (order.status) {
    case 'Pending':
      markerX = 30;
      markerY = 80;
      statusDesc = 'Awaiting seller confirmation...';
      break;
    case 'Accepted':
      markerX = 30;
      markerY = 80;
      statusDesc = 'Seller accepted your order!';
      break;
    case 'Preparing':
      markerX = 30;
      markerY = 80;
      statusDesc = 'Seller is preparing your package...';
      break;
    case 'Picked Up':
      markerX = 80;
      markerY = 80;
      statusDesc = 'Courier picked up package!';
      break;
    case 'On the Way':
      markerX = 160;
      markerY = 60;
      statusDesc = 'Courier is transit-bound...';
      break;
    case 'Delivered':
      markerX = 250;
      markerY = 40;
      statusDesc = 'Order delivered successfully!';
      break;
    case 'Cancelled':
      showMarker = false;
      statusDesc = order.cancelledBy ? `Cancelled by ${order.cancelledBy}` : 'Order was cancelled.';
      break;
  }

  document.getElementById('tracking-map-status').textContent = statusDesc;
  
  const courier = document.getElementById('map-courier-marker');
  if (courier) {
    courier.setAttribute('transform', `translate(${markerX},${markerY})`);
    courier.style.display = showMarker ? 'block' : 'none';
  }

  // Update step visual classes (Greyed out if Cancelled)
  document.querySelectorAll('.tracking-stepper').forEach(el => {
    el.style.opacity = isCancelled ? '0.4' : '1.0';
  });
  document.querySelectorAll('.tracking-map-container').forEach(el => {
    el.style.opacity = isCancelled ? '0.5' : '1.0';
  });

  // Update step visual classes
  updateStepUI('step-placed', currentStep >= 0, currentStep > 0, isCancelled);
  updateDividerUI('div-pickup', currentStep > 0);
  updateStepUI('step-pickup', currentStep >= 3, currentStep > 3, isCancelled);
  updateDividerUI('div-way', currentStep > 3);
  updateStepUI('step-way', currentStep >= 4, currentStep > 4, isCancelled);
  updateDividerUI('div-near', currentStep > 4);
  updateStepUI('step-near', currentStep >= 5, currentStep > 5, isCancelled);
  updateDividerUI('div-delivered', currentStep > 5);
  updateStepUI('step-delivered', currentStep >= 5, currentStep >= 5, isCancelled);

  // Set step timestamps
  document.getElementById('time-placed').textContent = 'Just Now';
  document.getElementById('time-pickup').textContent = currentStep >= 3 ? 'Completed' : 'Pending';
  document.getElementById('time-way').textContent = currentStep >= 4 ? 'Completed' : 'Pending';
  document.getElementById('time-near').textContent = currentStep >= 5 ? 'Completed' : 'Pending';
  document.getElementById('time-delivered').textContent = currentStep >= 5 ? 'Completed' : 'Pending';

  // Render activity log
  const logsList = document.getElementById('tracking-logs-list');
  if (logsList) {
    if (isCancelled) {
      logsList.innerHTML = `
        <div class="log-item latest">
          <span class="log-dot" style="background: #F44336;"></span>
          <div class="log-info">
            <span class="log-text" style="color: #F44336; font-weight:700;">This order has been cancelled.</span>
            <span class="log-time">Just Now</span>
          </div>
        </div>
      `;
    } else {
      let logsHtml = '';
      if (currentStep >= 5) {
        logsHtml += `
          <div class="log-item latest">
            <span class="log-dot" style="background: #4CAF50;"></span>
            <div class="log-info">
              <span class="log-text" style="font-weight: 700;">Order delivered successfully!</span>
              <span class="log-time">Just Now</span>
            </div>
          </div>
        `;
      }
      if (currentStep >= 4) {
        logsHtml += `
          <div class="log-item ${currentStep === 4 ? 'latest' : ''}">
            <span class="log-dot"></span>
            <div class="log-info">
              <span class="log-text">Courier is approaching your building (within 100m).</span>
              <span class="log-time">Recently</span>
            </div>
          </div>
        `;
      }
      if (currentStep >= 3) {
        logsHtml += `
          <div class="log-item ${currentStep === 3 ? 'latest' : ''}">
            <span class="log-dot"></span>
            <div class="log-info">
              <span class="log-text">Package picked up. Courier is transit-bound.</span>
              <span class="log-time">Recently</span>
            </div>
          </div>
        `;
      }
      logsHtml += `
        <div class="log-item ${currentStep === 0 ? 'latest' : ''}">
          <span class="log-dot"></span>
          <div class="log-info">
            <span class="log-text">Order placed successfully. Awaiting seller confirmation.</span>
            <span class="log-time">Just Now</span>
          </div>
        </div>
      `;
      logsList.innerHTML = logsHtml;
    }
  }
}

function updateStepUI(elementId, isActive, isCompleted, isCancelled) {
  const el = document.getElementById(elementId);
  if (!el) return;
  
  if (isCompleted) {
    el.classList.add('completed');
    el.classList.add('active');
  } else if (isActive) {
    el.classList.remove('completed');
    el.classList.add('active');
  } else {
    el.classList.remove('completed');
    el.classList.remove('active');
  }
}

function updateDividerUI(elementId, isCompleted) {
  const el = document.getElementById(elementId);
  if (!el) return;
  if (isCompleted) {
    el.classList.add('completed');
    el.classList.add('active');
  } else {
    el.classList.remove('completed');
    el.classList.remove('active');
  }
}

// ==========================================================================
// 10. SHOWCASE PRESENTATION TABS CONTROLLER & GRID INITIALIZER
// ==========================================================================

function setupShowcaseControllers() {
  // Theme controllers
  const body = document.body;
  const btnLight = document.getElementById('btn-theme-light');
  const btnDark = document.getElementById('btn-theme-dark');

  btnLight.addEventListener('click', () => {
    body.className = 'showcase-light';
    btnLight.classList.add('active');
    btnDark.classList.remove('active');
  });

  btnDark.addEventListener('click', () => {
    body.className = 'showcase-dark';
    btnDark.classList.add('active');
    btnLight.classList.remove('active');
  });

  // Showcase Tabs View switching (Interactive, Grid, Design System)
  const tabs = document.querySelectorAll('.view-tab-btn');
  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      tab.classList.add('active');

      const viewId = tab.id.replace('tab-', 'view-content-');
      document.querySelectorAll('.view-content').forEach(vc => vc.classList.remove('active'));
      document.getElementById(viewId).classList.add('active');

      if (tab.id === 'tab-grid') {
        initGridView();
      }
    });
  });

  // Sidebar screen navigation buttons inside Interactive Demo tab
  document.querySelectorAll('.nav-screen-link').forEach(link => {
    link.addEventListener('click', () => {
      const screenId = link.getAttribute('data-screen');
      navigateTo(screenId);
    });
  });

  // Status trigger handlers
  document.getElementById('btn-trigger-success').addEventListener('click', () => {
    showSuccessDialog('Triggered from case study controllers! Verified success status.');
  });
  
  document.getElementById('btn-trigger-error').addEventListener('click', () => {
    showErrorDialog('Mock transaction or connection failure. Code: 400 Bad Request.');
  });

  document.getElementById('btn-trigger-loading').addEventListener('click', () => {
    toggleSkeletonState();
  });

  // App Mode toggle controllers
  const btnLaunchApp = document.getElementById('btn-launch-app');
  const btnExitFullscreen = document.getElementById('btn-exit-fullscreen');

  if (btnLaunchApp) {
    btnLaunchApp.addEventListener('click', () => {
      body.classList.add('fullscreen-app-mode');
      showNotification('App Mode activated! Exit anytime using the float button.');
    });
  }

  if (btnExitFullscreen) {
    btnExitFullscreen.addEventListener('click', () => {
      body.classList.remove('fullscreen-app-mode');
      showNotification('Returned to case study view');
    });
  }
}

function initGridView() {
  const mockContainers = document.querySelectorAll('.mockup-iframe-container');
  mockContainers.forEach(container => {
    const screenType = container.getAttribute('data-screen-type');
    const phoneScreenTemplate = document.getElementById('phone-screen-root');
    if (!phoneScreenTemplate) return;

    // Clone the entire phone screen root
    const clonedScreenRoot = phoneScreenTemplate.cloneNode(true);
    
    // Find target screen in clone before stripping IDs
    const targetScreen = clonedScreenRoot.querySelector(`#scr-${screenType}`);
    
    // Deactivate all screens
    clonedScreenRoot.querySelectorAll('.screen-container').forEach(scr => {
      scr.classList.remove('active');
    });
    
    // Activate target screen
    if (targetScreen) {
      targetScreen.classList.add('active');
    }

    // Hide overlays inside mockups
    clonedScreenRoot.querySelectorAll('.modal-overlay, .bottom-sheet-overlay, .snackbar-toast').forEach(overlay => {
      overlay.classList.remove('active');
    });

    // Handle bottom navigation visibility in clone
    const bottomNav = clonedScreenRoot.querySelector('.phone-bottom-nav');
    const noNavScreens = ['splash', 'login', 'register', 'chat-screen'];
    if (bottomNav) {
      if (noNavScreens.includes(screenType)) {
        bottomNav.style.display = 'none';
      } else {
        bottomNav.style.display = 'flex';
        // Highlight active tab
        bottomNav.querySelectorAll('.nav-item').forEach(item => {
          if (item.getAttribute('data-tab') === screenType) {
            item.classList.add('active');
          } else {
            item.classList.remove('active');
          }
        });
      }
    }

    // Remove IDs from clones to prevent duplication in DOM
    clonedScreenRoot.removeAttribute('id');
    clonedScreenRoot.querySelectorAll('[id]').forEach(el => el.removeAttribute('id'));

    // Clear and append
    container.innerHTML = '';
    container.appendChild(clonedScreenRoot);
    
    // Convert icons to SVGs inside cloned screen
    replaceMaterialIcons(container);

    // Make the grid mockup clickable to load inside the live interactive simulator
    const parentItem = container.closest('.grid-mockup-item');
    if (parentItem) {
      parentItem.onclick = () => {
        const tabInteractive = document.getElementById('tab-interactive');
        if (tabInteractive) {
          tabInteractive.click();
        }
        navigateTo(screenType);
        document.getElementById('interactive-section').scrollIntoView({ behavior: 'smooth' });
        showNotification(`Loaded ${screenType.toUpperCase()} in interactive simulator`);
      };
    }
  });
}

// Initial boot
window.addEventListener('DOMContentLoaded', () => {
  updatePhoneClock();
  setInterval(updatePhoneClock, 60000);
  
  // Setup click listeners
  setupShowcaseControllers();
  
  // Pre-replace statically defined icons
  replaceMaterialIcons(document);
  
  // Parse launch queries to support direct login access and forced phone frames
  const urlParams = new URLSearchParams(window.location.search);
  const targetScreen = urlParams.get('screen') || 'login';

  // Initialize browser history state
  if (typeof history !== 'undefined' && history.replaceState) {
    history.replaceState({ screenId: targetScreen }, '', `#${targetScreen}`);
  }

  // Handle browser back / forward button clicks
  window.addEventListener('popstate', (event) => {
    if (event.state && event.state.screenId) {
      navigateTo(event.state.screenId, false);
    } else {
      const hash = window.location.hash.substring(1) || 'login';
      navigateTo(hash, false);
    }
  });
  
  if (urlParams.get('mode') === 'phone' || !window.matchMedia("(min-width: 1024px)").matches) {
    document.body.classList.add('fullscreen-app-mode');
    setTimeout(() => {
      const btnExit = document.getElementById('btn-exit-fullscreen');
      if (btnExit) btnExit.style.display = 'none';
    }, 100);
  }
  
  updateUIDisplays();

  // Initialize Auth state observer for Persistent Login / Session Restore
  if (typeof firebase !== 'undefined' && firebase.auth) {
    firebase.auth().onAuthStateChanged(async (user) => {
      if (user) {
        // Authenticated! Fetch profile from Firestore
        try {
          const doc = await firebase.firestore().collection('users').doc(user.uid).get();
          if (doc.exists) {
            currentUser = doc.data();
            localStorage.setItem('currentUser', JSON.stringify(currentUser));
            updateUIDisplays();
            
            // Route directly to feed if at login/splash
            if (currentScreen === 'login' || currentScreen === 'splash') {
              navigateTo('home');
            }
          } else {
            // New user signed in but didn't finish onboarding yet
            currentUser = {
              uid: user.uid,
              fullName: user.displayName || 'New Student',
              email: user.email || '',
              profilePhoto: user.photoURL || '',
              phoneNumber: user.phoneNumber || '',
              college: 'SRM University',
              department: '',
              year: '',
              bio: '',
              createdAt: new Date().toISOString(),
              lastLogin: new Date().toISOString(),
              authenticationProvider: 'Google',
              role: 'Student',
              status: 'Active'
            };
            localStorage.setItem('currentUser', JSON.stringify(currentUser));
            
            // Fill onboarding inputs
            document.getElementById('onboard-name-input').value = currentUser.fullName;
            document.getElementById('onboard-email-input').value = currentUser.email;
            document.getElementById('onboard-phone-input').value = currentUser.phoneNumber || '';
            
            // Show onboarding
            document.getElementById('auth-step-google').style.display = 'none';
            document.getElementById('auth-step-onboarding').style.display = 'block';
            document.getElementById('auth-main-title').textContent = 'Complete Profile';
            document.getElementById('auth-sub-title').textContent = 'Just a few details to activate your student account';
            navigateTo('login');
          }
        } catch (e) {
          console.error("Auth state Firestore fetch error:", e);
        }
      } else {
        // Logged out
        currentUser = null;
        localStorage.removeItem('currentUser');
        navigateTo('login');
      }
    });
  } else {
    // Local / Offline fallback
    if (currentUser) {
      navigateTo('home');
    } else {
      navigateTo('login');
    }
  }

  // Initialize shared database sync
  loadSharedDatabase();
});

// ==========================================================================
// GOOGLE & FIREBASE AUTHENTICATION FLOWS
// ==========================================================================

function updateUIDisplays() {
  if (currentUser) {
    const displayName = currentUser.fullName || currentUser.name || 'New Student';
    const displayEmail = currentUser.email || '';
    const displayInitials = (currentUser.initials || displayName.split(' ').map(n=>n[0]).join('').toUpperCase()).slice(0, 2);
    const photoUrl = currentUser.profilePhoto || '';

    document.querySelectorAll('.profile-name').forEach(el => el.textContent = displayName);
    document.querySelectorAll('.profile-email').forEach(el => el.textContent = displayEmail);
    
    document.querySelectorAll('.profile-avatar-large').forEach(el => {
      if (photoUrl) {
        el.innerHTML = `<img src="${photoUrl}" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">`;
      } else {
        el.textContent = displayInitials;
      }
    });
    
    const collegePill = document.querySelector('.badge-pill.bg-primary-light');
    if (collegePill) {
      collegePill.textContent = `${currentUser.college || 'SRM University'} • ${currentUser.year || 'Student'}`;
    }
  }
}
window.updateUIDisplays = updateUIDisplays;

async function handleGoogleSignIn() {
  const isDemoConfig = typeof firebaseConfig === 'undefined' || firebaseConfig.apiKey.includes("placeholder");
  
  if (isDemoConfig) {
    showLoading(true);
    setTimeout(() => {
      // Simulate selecting a mock Google account when the API keys are placeholders
      const mockGoogleUser = {
        uid: "google_student_12345",
        displayName: "Jeyashanth",
        email: "jeyashanth@srmist.edu.in",
        photoURL: "https://api.dicebear.com/7.x/initials/svg?seed=Jeyashanth",
        phoneNumber: "+91 98765 43210"
      };
      processUserSignIn(mockGoogleUser);
      showLoading(false);
    }, 1000);
    return;
  }

  if (typeof firebase === 'undefined' || !firebase.auth) {
    showNotification("Firebase Auth SDK is not loaded.");
    return;
  }
  showLoading(true);
  try {
    const provider = new firebase.auth.GoogleAuthProvider();
    const result = await firebase.auth().signInWithPopup(provider);
    const user = result.user;
    await processUserSignIn(user);
  } catch (error) {
    console.error("Google Sign-In Error:", error);
    showNotification(`Google Sign-In failed: ${error.message}`);
  } finally {
    showLoading(false);
  }
}

async function handleGoogleCredentialResponse(response) {
  if (typeof firebase === 'undefined' || !firebase.auth) {
    showNotification("Firebase Auth SDK is not loaded.");
    return;
  }
  showLoading(true);
  try {
    const credential = firebase.auth.GoogleAuthProvider.credential(response.credential);
    const result = await firebase.auth().signInWithCredential(credential);
    const user = result.user;
    await processUserSignIn(user);
  } catch (error) {
    console.error("Google One Tap error:", error);
    showNotification(`Google One Tap sign in failed: ${error.message}`);
  } finally {
    showLoading(false);
  }
}
async function processUserSignIn(user) {
  try {
    const userDocRef = firebase.firestore().collection('users').doc(user.uid);
    const doc = await userDocRef.get();
    
    if (doc.exists) {
      // Returning user -> restore previous login session
      const userData = doc.data();
      
      // Update last login timestamp in Firestore
      await userDocRef.update({
        lastLogin: new Date().toISOString()
      });
      
      currentUser = userData;
      localStorage.setItem('currentUser', JSON.stringify(currentUser));
      updateUIDisplays();
      showNotification(`Welcome back, ${currentUser.fullName || currentUser.name}!`);
      navigateTo('home');
    } else {
      // New user -> Onboarding Complete Profile redirect!
      currentUser = {
        uid: user.uid,
        fullName: user.displayName || '',
        email: user.email || '',
        profilePhoto: user.photoURL || '',
        phoneNumber: user.phoneNumber || '',
        college: 'SRM University', // default
        department: '',
        year: '',
        bio: '',
        createdAt: new Date().toISOString(),
        lastLogin: new Date().toISOString(),
        authenticationProvider: 'Google',
        role: 'Student',
        status: 'Active'
      };
      
      localStorage.setItem('currentUser', JSON.stringify(currentUser));
      
      // Fill in Onboarding fields
      document.getElementById('onboard-name-input').value = currentUser.fullName;
      document.getElementById('onboard-email-input').value = currentUser.email;
      document.getElementById('onboard-phone-input').value = currentUser.phoneNumber || '';
      
      // Show onboarding form
      document.getElementById('auth-step-google').style.display = 'none';
      document.getElementById('auth-step-onboarding').style.display = 'block';
      document.getElementById('auth-main-title').textContent = 'Complete Profile';
      document.getElementById('auth-sub-title').textContent = 'Just a few details to activate your student account';
    }
  } catch (err) {
    console.error("Error processing user sign-in:", err);
    showNotification("Error loading profile from database.");
  }
}

async function completeOnboarding() {
  const phone = document.getElementById('onboard-phone-input').value.trim();
  const college = document.getElementById('onboard-college-input').value;
  const dept = document.getElementById('onboard-dept-input').value.trim();
  const year = document.getElementById('onboard-year-input').value.trim();
  const bio = document.getElementById('onboard-bio-input').value.trim();
  
  if (!phone) {
    showNotification('Please enter your phone number.');
    return;
  }
  if (!dept) {
    showNotification('Please enter your department.');
    return;
  }
  if (!year) {
    showNotification('Please enter your year of study.');
    return;
  }

  showLoading(true);
  try {
    currentUser.phoneNumber = phone;
    currentUser.college = college;
    currentUser.department = dept;
    currentUser.year = year;
    currentUser.bio = bio;
    currentUser.lastLogin = new Date().toISOString();
    
    // Save document to Firestore
    await firebase.firestore().collection('users').doc(currentUser.uid).set(currentUser);
    
    localStorage.setItem('currentUser', JSON.stringify(currentUser));
    updateUIDisplays();
    
    showNotification('Student profile activated successfully!');
    navigateTo('home');
  } catch (error) {
    console.error("Error completing onboarding:", error);
    showNotification(`Profile registration failed: ${error.message}`);
  } finally {
    showLoading(false);
  }
}

function openEditProfileModal() {
  if (!currentUser) return;
  document.getElementById('edit-profile-name').value = currentUser.fullName || currentUser.name || '';
  document.getElementById('edit-profile-phone').value = currentUser.phoneNumber || '';
  document.getElementById('edit-profile-college').value = currentUser.college || 'SRM University';
  document.getElementById('edit-profile-dept').value = currentUser.department || '';
  document.getElementById('edit-profile-year').value = currentUser.year || '';
  document.getElementById('edit-profile-bio').value = currentUser.bio || '';
  document.getElementById('edit-profile-photo').value = currentUser.profilePhoto || '';
  
  document.getElementById('comp-edit-profile-modal').classList.add('active');
}

async function submitEditProfile() {
  const name = document.getElementById('edit-profile-name').value.trim();
  const phone = document.getElementById('edit-profile-phone').value.trim();
  const college = document.getElementById('edit-profile-college').value.trim();
  const dept = document.getElementById('edit-profile-dept').value.trim();
  const year = document.getElementById('edit-profile-year').value.trim();
  const bio = document.getElementById('edit-profile-bio').value.trim();
  const photo = document.getElementById('edit-profile-photo').value.trim();
  
  if (!name || !phone || !college || !dept || !year) {
    showNotification("Please fill in all required fields.");
    return;
  }
  
  showLoading(true);
  try {
    currentUser.fullName = name;
    currentUser.phoneNumber = phone;
    currentUser.college = college;
    currentUser.department = dept;
    currentUser.year = year;
    currentUser.bio = bio;
    currentUser.profilePhoto = photo;
    currentUser.lastLogin = new Date().toISOString();
    
    // Save to Firestore
    await firebase.firestore().collection('users').doc(currentUser.uid).set(currentUser);
    
    localStorage.setItem('currentUser', JSON.stringify(currentUser));
    updateUIDisplays();
    closeModal('comp-edit-profile-modal');
    showNotification("Profile updated successfully!");
  } catch (error) {
    console.error("Error updating profile:", error);
    showNotification(`Failed to save changes: ${error.message}`);
  } finally {
    showLoading(false);
  }
}

async function logoutUser() {
  showLoading(true);
  try {
    if (typeof firebase !== 'undefined' && firebase.auth) {
      await firebase.auth().signOut();
    }
    currentUser = null;
    localStorage.removeItem('currentUser');
    
    // Reset login steps visibility
    document.getElementById('auth-step-google').style.display = 'block';
    document.getElementById('auth-step-onboarding').style.display = 'none';
    document.getElementById('auth-main-title').textContent = 'CampusConnect';
    document.getElementById('auth-sub-title').textContent = 'Sign in with your student Google account to get started';
    
    showNotification("Logged out successfully.");
    navigateTo('login');
  } catch (error) {
    console.error("Logout error:", error);
    showNotification("Error logging out.");
  } finally {
    showLoading(false);
  }
}

async function deleteUserAccount() {
  if (!confirm("Are you sure you want to permanently delete your CampusConnect student account? This action cannot be undone.")) {
    return;
  }
  showLoading(true);
  try {
    const user = firebase.auth().currentUser;
    if (user) {
      // 1. Delete document from Firestore
      await firebase.firestore().collection('users').doc(user.uid).delete();
      
      // 2. Delete Auth account
      await user.delete();
    }
    currentUser = null;
    localStorage.removeItem('currentUser');
    closeModal('comp-edit-profile-modal');
    
    document.getElementById('auth-step-google').style.display = 'block';
    document.getElementById('auth-step-onboarding').style.display = 'none';
    document.getElementById('auth-main-title').textContent = 'CampusConnect';
    document.getElementById('auth-sub-title').textContent = 'Sign in with your student Google account to get started';
    
    showNotification("Account permanently deleted.");
    navigateTo('login');
  } catch (error) {
    console.error("Delete account error:", error);
    showNotification(`Delete failed: ${error.message}. Please re-authenticate and try again.`);
  } finally {
    showLoading(false);
  }
}

function showLoading(active) {
  const overlay = document.getElementById('auth-loading-overlay');
  if (overlay) {
    overlay.style.display = active ? 'flex' : 'none';
  }
}
async function uploadProfilePhoto(event) {
  const file = event.target.files[0];
  if (!file || !currentUser) return;
  
  showLoading(true);
  try {
    showNotification('Uploading profile photo...');
    const path = `users/${currentUser.uid}/profile_${Date.now()}`;
    const downloadURL = await uploadFileToFirebase(file, path);
    document.getElementById('edit-profile-photo').value = downloadURL;
    showNotification('Profile photo uploaded successfully!');
  } catch (error) {
    console.error("Profile photo upload failed:", error);
    showNotification(`Upload failed: ${error.message}`);
  } finally {
    showLoading(false);
  }
}

window.handleGoogleSignIn = handleGoogleSignIn;
window.handleGoogleCredentialResponse = handleGoogleCredentialResponse;
window.openEditProfileModal = openEditProfileModal;
window.submitEditProfile = submitEditProfile;
window.logoutUser = logoutUser;
window.deleteUserAccount = deleteUserAccount;
window.completeOnboarding = completeOnboarding;
window.uploadProfilePhoto = uploadProfilePhoto;

// Shared Real-Time JSON Database Sync Helpers (using api.npoint.io)
let binId = null;

async function loadSharedDatabase() {
  const urlParams = new URLSearchParams(window.location.search);
  binId = urlParams.get('bin') || localStorage.getItem('cc_shared_bin_id');

  if (!binId) {
    // Dynamically create a new sharing bin on npoint.io
    try {
      const res = await fetch("https://api.npoint.io", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ products: [], chats: [], users: [] })
      });
      if (res.ok) {
        const data = await res.json();
        binId = data.id;
        localStorage.setItem('cc_shared_bin_id', binId);
        
        // Append to URL query without refreshing the page
        urlParams.set('bin', binId);
        window.history.replaceState({}, '', `${window.location.pathname}?${urlParams.toString()}`);
        showNotification("Created new sharing space! Copy URL to invite friends.");
      }
    } catch (err) {
      console.warn("Failed to create sharing bin:", err);
    }
  } else {
    localStorage.setItem('cc_shared_bin_id', binId);
    if (!urlParams.get('bin')) {
      urlParams.set('bin', binId);
      window.history.replaceState({}, '', `${window.location.pathname}?${urlParams.toString()}`);
    }
  }

  if (binId) {
    await syncFromBin();
    setInterval(syncFromBin, 3000); // sync every 3s
  }
}

async function syncFromBin() {
  if (!binId) return;
  try {
    const res = await fetch(`https://api.npoint.io/${binId}`);
    if (res.ok) {
      const data = await res.json();
      if (data) {
        if (Array.isArray(data.products)) {
          products = data.products;
          renderHomeListings();
        }
        if (Array.isArray(data.chats)) {
          chats = data.chats;
          renderChatsList();
          if (currentChatId) {
            const chat = chats.find(c => c.id === currentChatId);
            if (chat) renderActiveBubbles(chat);
          }
        }
        if (Array.isArray(data.users)) {
          users = data.users;
        }
      }
    }
  } catch (err) {
    console.warn("Sync failed:", err);
  }
}

async function saveToBin() {
  if (!binId) return;
  try {
    await fetch(`https://api.npoint.io/${binId}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ products, chats, users })
    });
  } catch (err) {
    console.warn("Save failed:", err);
  }
}

// Map old helpers to the new unified KV bin save
function saveSharedProducts() {
  saveToBin();
}
function saveSharedChats() {
  saveToBin();
}

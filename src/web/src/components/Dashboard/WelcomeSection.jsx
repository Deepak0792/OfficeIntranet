import React, { useState, useEffect } from 'react';

export default function WelcomeSection() {
  const [time, setTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => setTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  const formattedTime = time.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
  const formattedDate = time.toLocaleDateString([], { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });

  // Simple greeting based on time of day
  const hour = time.getHours();
  let greeting = 'Good evening';
  if (hour < 12) greeting = 'Good morning';
  else if (hour < 17) greeting = 'Good afternoon';

  const motivationalQuotes = [
    "Productivity is never an accident. It is always the result of a commitment to excellence.",
    "Individually we are one drop. Together, we are an ocean. Let's make an impact today!",
    "The strength of the team is each individual member. The strength of each member is the team.",
    "Do not wait for opportunities, create them. Have a productive day at the office!",
    "Excellence is not a skill, it's an attitude. Let's build something great today."
  ];

  // Pick quote based on day of month
  const quoteIndex = time.getDate() % motivationalQuotes.length;
  const activeQuote = motivationalQuotes[quoteIndex];

  return (
    <div className="welcome-container">
      <div className="welcome-profile">
        <img 
          src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150" 
          alt="Sarah Connor avatar" 
          className="welcome-avatar" 
        />
        <div className="welcome-text">
          <h2>{greeting}, Sarah!</h2>
          <p style={{ fontSize: '0.95rem', fontWeight: 500 }}>Welcome back to your intranet command center.</p>
          <div className="welcome-quote">"{activeQuote}"</div>
        </div>
      </div>

      <div className="welcome-time-box">
        <span className="welcome-time">{formattedTime}</span>
        <span className="welcome-date">{formattedDate}</span>
      </div>
    </div>
  );
}

import React from 'react';

export default function Accounts({
  accounts=[],
  onSeletectAccount
}) {
  return ()
    <div className="pure-menu sidebar">
      <span className="pure-menu-heading">account list</span>

      <ul className="pure-menu-list">
        { accounts.map(account => (
          // <li className="pure-menu-item" key={account} onClick={onSelect}
            <a href="#" className="pure-menu-link">{account}</a>
          </li>))
        }
      </ul>
    </div>
  );
}

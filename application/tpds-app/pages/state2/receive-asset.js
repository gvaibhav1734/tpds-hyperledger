import Head from 'next/head'
import Link from 'next/link'

export default function Home() {

    var txn_response = '';

    const receiveAsset = async event => {
        event.preventDefault();
        var recreq = JSON.stringify({
            ID: event.target.id.value,
            From: event.target.from.value,
            To: event.target.to.value
        });
        console.log(`recreq: ${recreq}`);
        const res = await fetch('/api/receiveAsset2', {
            body: recreq,
            headers: {
                'Content-Type': 'application/json'
            },
            method: 'POST'
        })
        console.log(`txn response: ${txn_response}`);
        const result = await res.json();
        txn_response = result.status;
        if (txn_response == null) {
            txn_response = "Receive Transaction Failed (might be leakage)";
        }
        document.getElementById("resp").innerHTML = txn_response;
        console.log(`result: ${JSON.stringify(result)}`);
        console.log(`txn response: ${txn_response}`);
    }

  return (
    <div className="container">
      <Head>
        <title>TPDS Blockchain: State 2</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main>
        <h1 className="title">
          State 2: Receive Asset
        </h1>

        <p className="description">
          Enter details:
        </p>

        <div className="grid">
            <form onSubmit={receiveAsset}>
                <label htmlFor="id">ID</label> <br></br>
                <input id="id" name="id" type="text" className="tb" required /> <br></br>
                <label htmlFor="from">From</label> <br></br>
                <input id="from" name="from" type="text" className="tb" required /> <br></br>
                <label htmlFor="to">To</label> <br></br>
                <input id="to" name="to" type="text" className="tb" required /> <br></br>
                <button type="submit" className="button button1" >Receive</button>
            </form>
        </div>

        <div className="grid"> 
            <p id="resp"></p>
        </div>
      </main>

      <style jsx>{`
        .container {
          min-height: 100vh;
          padding: 0 0.5rem;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
        }

        main {
          padding: 5rem 0;
          flex: 1;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
        }

        footer {
          width: 100%;
          height: 100px;
          border-top: 1px solid #eaeaea;
          display: flex;
          justify-content: center;
          align-items: center;
        }

        footer img {
          margin-left: 0.5rem;
        }

        footer a {
          display: flex;
          justify-content: center;
          align-items: center;
        }

        a {
          color: inherit;
          text-decoration: none;
        }

        .title a {
          color: #0070f3;
          text-decoration: none;
        }

        .title a:hover,
        .title a:focus,
        .title a:active {
          text-decoration: underline;
        }

        .title {
          margin: 0;
          line-height: 1.15;
          font-size: 4rem;
        }

        .title,
        .description {
          text-align: center;
        }

        .description {
          line-height: 1.5;
          font-size: 1.5rem;
        }

        code {
          background: #fafafa;
          border-radius: 5px;
          padding: 0.75rem;
          font-size: 1.1rem;
          font-family: Menlo, Monaco, Lucida Console, Liberation Mono,
            DejaVu Sans Mono, Bitstream Vera Sans Mono, Courier New, monospace;
        }

        .grid {
          display: flex;
          align-items: center;
          justify-content: center;
          flex-wrap: wrap;

          max-width: 800px;
          margin-top: 3rem;
        }

        .card {
          margin: 1rem;
          flex-basis: 45%;
          padding: 1.5rem;
          text-align: left;
          color: inherit;
          text-decoration: none;
          border: 1px solid #eaeaea;
          border-radius: 10px;
          transition: color 0.15s ease, border-color 0.15s ease;
        }

        .card:hover,
        .card:focus,
        .card:active {
          color: #0070f3;
          border-color: #0070f3;
        }

        .card h3 {
          margin: 0 0 1rem 0;
          font-size: 1.5rem;
        }

        .card p {
          margin: 0;
          font-size: 1.25rem;
          line-height: 1.5;
        }

        .logo {
          height: 1em;
        }

        .button {
            border: none;
            color: white;
            padding: 16px 32px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 4px 2px;
            transition-duration: 0.4s;
            cursor: pointer;
        }
          
        .button1 {
            background-color: white; 
            color: black; 
            border: 2px solid #008CBA;
        }
          
        .button1:hover {
            background-color: #008CBA;
            color: white;
        }

        .tb {
            padding: 16px 32px;
            text-align: center;
            text-decoration: none;
            display: inline-block;
            font-size: 16px;
            margin: 4px 2px;
            transition-duration: 0.4s;
            cursor: pointer;
        }

        @media (max-width: 600px) {
          .grid {
            width: 100%;
            flex-direction: column;
          }
        }
      `}</style>

      <style jsx global>{`
        html,
        body {
          padding: 0;
          margin: 0;
          font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto,
            Oxygen, Ubuntu, Cantarell, Fira Sans, Droid Sans, Helvetica Neue,
            sans-serif;
        }

        * {
          box-sizing: border-box;
        }
      `}</style>
    </div>
  )
}

// $Id$

/*
 Copyright (c) 2014-2020, Trustees of The University of Cantabria
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

 Redistributions of source code must retain the above copyright notice, this 
 list of conditions and the following disclaimer.
 Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef _BYPASS_ARB_FBFCL_ROUTER_HPP_
#define _BYPASS_ARB_FBFCL_ROUTER_HPP_

#include <string>
#include <deque>
#include <queue>
#include <set>
#include <map>

#include "../router.hpp"
#include "../../routefunc.hpp"
#include "../../arbiters/arbiter.hpp"

namespace Booksim
{

    using namespace std;

    class VC;
    class Flit;
    class Credit;
    class Buffer;
    class BufferState;
    class Allocator;
    //class SwitchMonitor;
    //class BufferMonitor;


    class BypassArbFBFCLRouter : public Router {
        struct BypassOutput {
            int output_port;
            int dest_vc;
            OutputSet la_route_set;
            //int pid;
        };

        // Number of virtual channels per channel
        int _vcs;

        // Is the router active?
        bool _active;
        
        vector<Credit *> _proc_credits;

        // Stage communication
        vector<pair<Flit *, int>> _crossbar_flits;

        // SA-I input (expanded inputs with flits)
        vector<bool> _switch_arbiter_input_flits;
        
        map<int, Flit *> _buffer_write_flits; // (output port, expanded_input)

        // Lookahead Check Conflict
        vector<pair<Lookahead *, int>> _lookahead_conflict_check_lookaheads; // (Lookahead, input)
        map<int, int> _lookahead_conflict_check_flits; // (output port, expanded_input)
        // SA-O input
        map<int, Flit *> _switch_arbiter_output_flits; // input, Flit

        // Input buffer (input VCs)
        vector<Buffer *> _buf;
        // output buffer state (output VCs)
        vector<BufferState *> _next_buf;

        // SA arbiters
        vector<Arbiter *> _switch_arbiter_input;
        vector<Arbiter *> _switch_arbiter_output;

        // Routing function
        tRoutingFunction _rf;

        // Bypass paths
        vector<bool> _bypass_path;
        // Only for dateline routing: used to copy ph field from LA to a Flit
        vector<int> _dateline_partition;

        // Give priority to LA over flits: 1 or Flits over LA: 0
        bool _lookaheads_kill_flits;
                    
        // If a trail flit is stored the LAs of following flits are ignored
        //vector<int> _lookahead_buffered_flits;
        map<int,bool> _lookahead_buffered_flits;

        // Output buffer size and output buffer
        int _output_buffer_size;
        vector<queue<Flit *> > _output_buffer;

        vector<Credit *> _credit_buffer;

        vector<Lookahead *> _lookahead_buffer;

        // Reads incoming flits
        bool _ReceiveFlits();
        // Reads incoming credits 
        bool _ReceiveCredits();
        // Reads incoming lookahead information
        bool _ReceiveLookahead();

        // Internal step (called by Network::Evaluate())
        virtual void _InternalStep();

        void _BufferWrite();
        void _SwitchArbiterInput();
        void _SwitchArbiterOutput();
        void _LookAheadConflictCheck();
        void _LookAheadRouteCompute(Flit *f, int output_port);

        // Output_Stage: ST
        void _Output_Stage();
        void _SwitchTraversal();

        // pre-LT
        void _OutputQueuing();

        // Used in WriteOuputs()
        void _SendFlits();
        void _SendCredits();
        void _SendLookahead();

        // disables bypass
        int _disable_bypass;

        // optimization for single flit packets
        bool _single_flit_optimization;

        string _switch_arbiter_input_policy;
        vector<int> _switch_arbiter_input_winner;

        public:

        BypassArbFBFCLRouter( Configuration const & config,
                Module *parent, string const & name, int id,
                int inputs, int outputs );

        virtual ~BypassArbFBFCLRouter( );

        virtual void ReadInputs( );
        virtual void WriteOutputs( );
        
        void Display( ostream & os = cout ) const;

        // FIXME: What is this shit.
        virtual int GetUsedCredit(int o) const { return 0;}
        virtual int GetUsedCreditVC(int o, int vc) const {return 0;} //(I)
        virtual int GetBufferOccupancy(int i) const {return 0;}

#ifdef TRACK_BUFFERS
        virtual int GetUsedCreditForClass(int output, int cl) const {return 0;};
        virtual int GetBufferOccupancyForClass(int input, int cl) const {return 0;};
#endif

        virtual vector<int> UsedCredits() const { vector<int> result; return result;}
        virtual vector<int> FreeCredits() const { vector<int> result; return result;}
        virtual vector<int> MaxCredits() const { vector<int> result; return result;}

    };
} // namespace Booksim

#endif
